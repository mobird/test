/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "PhysicsLayer.h"
#import "vector"
#import "TileMapLayer.h"
#import "InputLayer.h"

#import "SimpleAudioEngine.h"

static int old = -1;
static int newPos = -1;
static bool tap = false;




//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
const float PTM_RATIO = 32.0f;

const int TILESIZE = 32;
const int TILESET_COLUMNS = 9;
const int TILESET_ROWS = 19;

typedef enum _STATE {
    INIT = 0,
    BEGIN = 1,
    END = 2,
} STATE;

static STATE g_state = INIT;
b2Body *g_ball = NULL;
b2Body *g_plan = NULL;
b2World* g_world = NULL;
std::vector<b2Body *> g_list;

@interface PhysicsLayer (PrivateMethods)
-(void) enableBox2dDebugDrawing;
-(void) addSomeJoinedBodies:(CGPoint)pos;
-(void) addNewSpriteAt:(CGPoint)p  index:(int)index;
-(b2Vec2) toMeters:(CGPoint)point;
-(CGPoint) toPixels:(b2Vec2)vec;

-(CCSprite*) addSpriteAt:(CGPoint)pos index:(int)i;
-(void) bodyCreateFixture:(b2Body*)body;
@end

@implementation PhysicsLayer

-(CGRect) getRectFromObjectProperties:(NSDictionary*)dict tileMap:(CCTMXTiledMap*)tileMap
{
	float x, y, width, height;
	x = [[dict valueForKey:@"x"] floatValue] + tileMap.position.x;
	y = [[dict valueForKey:@"y"] floatValue] + tileMap.position.y;
	width = [[dict valueForKey:@"width"] floatValue];
    if (width == 0) {
        width = 40;
    }
	height = [[dict valueForKey:@"height"] floatValue];
    if (height == 0) {
        height = 80;
    }
	
	return CGRectMake(x, y, width, height);
}

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@ init", NSStringFromClass([self class]));
        
        // Load all of the game's artwork up front.
		CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[frameCache addSpriteFramesWithFile:@"e1_down.plist"];
        
		[frameCache addSpriteFramesWithFile:@"ball_default.plist"];
        

        
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
        
        
        TileMapLayer *layer = [[TileMapLayer alloc] init];
        [self addChild:layer z:-1];
        
        //InputLayer* inputLayer = [InputLayer node];
        //[self addChild:inputLayer z:2 tag:222];


		glClearColor(0.1f, 0.0f, 0.2f, 1.0f);
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		b2Vec2 gravity = b2Vec2(-3.0f, 0.0f);//-10.0f);
		world = new b2World(gravity);
		world->SetAllowSleeping(YES);
		world->SetContinuousPhysics(NO);
		
		// uncomment this line to draw debug info
		//[self enableBox2dDebugDrawing];

        contactListener = new ContactListener();
        world->SetContactListener(contactListener);
        g_world = world;
		
		// for the screenBorder body we'll need these values
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		float widthInMeters = screenSize.width / PTM_RATIO;
		float heightInMeters = (screenSize.height-80) / PTM_RATIO;
		b2Vec2 lowerLeftCorner = b2Vec2(0, 0);
		b2Vec2 lowerRightCorner = b2Vec2(widthInMeters, 0);
		b2Vec2 upperLeftCorner = b2Vec2(0, heightInMeters);
		b2Vec2 upperRightCorner = b2Vec2(widthInMeters, heightInMeters);
		
		// Define the static container body, which will provide the collisions at screen borders.
		b2BodyDef screenBorderDef;
        screenBorderDef.bullet = true;
		screenBorderDef.position.Set(0, 0);
		b2Body* screenBorderBody = world->CreateBody(&screenBorderDef);
        screenBorderBody->SetUserData(NULL);
		b2EdgeShape screenBorderShape;
		
		// Create fixtures for the four borders (the border shape is re-used)
		screenBorderShape.Set(lowerLeftCorner, lowerRightCorner);
        
        b2FixtureDef def;
        def.shape = &screenBorderShape;
        def.density = 0;
        def.restitution = 1;
		//screenBorderBody->CreateFixture(&screenBorderShape, 0);
        screenBorderBody->CreateFixture(&def);
        
		screenBorderShape.Set(lowerRightCorner, upperRightCorner);
		screenBorderBody->CreateFixture(&def);//(&screenBorderShape, 0);
        
		screenBorderShape.Set(upperRightCorner, upperLeftCorner);
		screenBorderBody->CreateFixture(&def);//(&screenBorderShape, 0);
        
		screenBorderShape.Set(upperLeftCorner, lowerLeftCorner);
		screenBorderBody->CreateFixture(&def);//(&screenBorderShape, 0);
		
		NSString* message = @"Flipboard game by mobird.";//@"Tap Screen For More Awesome!";
		if ([CCDirector sharedDirector].currentPlatformIsMac)
		{
			message = @"Flipboard game by mobird.";//@"Click Window For More Awesome!";
		}
		/*
		CCLabelTTF* label = [CCLabelTTF labelWithString:message fontName:@"Marker Felt" fontSize:32];
		[self addChild:label];
		[label setColor:ccc3(222, 222, 255)];
		label.position = CGPointMake(screenSize.width / 2, screenSize.height - 50);
         */
		
		// Use the orthogonal tileset for the little boxes
		CCSpriteBatchNode* batch = [CCSpriteBatchNode batchNodeWithFile:@"e1-hd.png" capacity:TILESET_ROWS * TILESET_COLUMNS];
		[self addChild:batch z:0 tag:kTagBatchNode];

		
		// Add a few objects initially
//		for (int i = 0; i < 10; i++)
//		{
//			//[self addNewSpriteAt:CGPointMake(screenSize.width / 2, screenSize.height / 2)];
//            if (i % 2 != 0) {
//                [self addNewSpriteAt:CGPointMake(screenSize.width * 0.1, (i) * (screenSize.height / 10.0))];
//            }		
//        }
        
//        CCSpriteBatchNode* batchEnemies = [CCSpriteBatchNode batchNodeWithFile:@"enemies.png" capacity:1 * 2];
//		[self addChild:batchEnemies z:1 tag:111];
//        
//        CGRect tileRect = CGRectMake(80 * 0, 160 * 0, 80, 160);
//        
//        CCSprite* sprite = [CCSprite spriteWithBatchNode:batchEnemies rect:tileRect];
//        sprite.position = ccp(100, 100);;
//        sprite.scale = 1/2.0;
//        [batchEnemies addChild:sprite]; 
        
        //add a plan
        //get position
        //add map objects
        CCNode* node = [layer getChildByTag:TileMapNode];
        NSAssert([node isKindOfClass:[CCTMXTiledMap class]], @"not a CCTMXTiledMap");
        CCTMXTiledMap* tileMap = (CCTMXTiledMap*)node;
        CCTMXObjectGroup* playerLayer = [tileMap objectGroupNamed:@"player"];
        NSAssert([playerLayer isKindOfClass:[CCTMXObjectGroup class]], @"playerlayer not found or not a CCTMXObjectGroup");

        NSDictionary* properties = [playerLayer objectNamed:@"player"];
        //NSDictionary* properties = [[playerLayer objects] objectAtIndex:0];
        CGRect rect = [self getRectFromObjectProperties:properties tileMap:tileMap];

        
        CCSprite* player = [CCSprite spriteWithFile:@"player.png"];
        player.anchorPoint = CGPointMake(0.5, 0.5 );
        player.position = ccp(rect.origin.x/CC_CONTENT_SCALE_FACTOR() + 128/2/CC_CONTENT_SCALE_FACTOR(), rect.origin.y/CC_CONTENT_SCALE_FACTOR() + 128/2/CC_CONTENT_SCALE_FACTOR());
        //[batch addChild:sprite];
        [self addChild:player z:2];
        
        // create an animation object from all the sprite animation frames
		CCAnimation* anim = [CCAnimation animationWithFrames:@"e1_down-hd_" frameCount:30 delay:0.1f];
		
		// run the animation by using the CCAnimate action
		CCAnimate* animate = [CCAnimate actionWithAnimation:anim];
		CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
		[player runAction:repeat];

        
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.bullet = true;
        bodyDef.linearDamping = 100;
        
        
        // position must be converted to meters
        bodyDef.position = [self toMeters:ccp(player.position.x, player.position.y)];
        bodyDef.userData = (__bridge void*)player;
        b2Body* bodyA = world->CreateBody(&bodyDef);
        bodyDef.linearDamping = 0;
        [self bodyCreateFixture:bodyA];
        
        g_plan = bodyA;
        
        //add joint
        b2PrismaticJointDef jointDef;
        b2Vec2 worldAxis(0.0f, 1.0f);
        jointDef.Initialize(bodyA, screenBorderBody, bodyA->GetWorldCenter(), worldAxis);
        jointDef.lowerTranslation = -heightInMeters/2 + 16/PTM_RATIO;//-3.0f; 
        jointDef.upperTranslation = heightInMeters/2+16/PTM_RATIO;//3.0f; 
        jointDef.enableLimit = true; 
        jointDef.maxMotorForce = 10000000.0f; 
        jointDef.motorSpeed = 0.0f; 
        jointDef.enableMotor = true;
        
        joint = (b2PrismaticJoint*)g_world->CreateJoint(&jointDef);
        
        // get the object layer
        // enemise
        CCTMXObjectGroup* objectLayer = [tileMap objectGroupNamed:@"enemy"];
        NSAssert([objectLayer isKindOfClass:[CCTMXObjectGroup class]], @"ObjectLayer not found or not a CCTMXObjectGroup");
        
        NSUInteger numObjects = [[objectLayer objects] count];
        for (NSUInteger i = 0; i < numObjects; i++)
        {
            //CCLOG(@"---%@-----", i);
            NSDictionary* properties = [[objectLayer objects] objectAtIndex:i];
            int gid = [[properties valueForKey:@"red"] intValue];
            NSLog(@"-----%@------", properties);
            int index = 0;
            if (gid == 1) {
                index = 1;
            }
            CGRect rect = [self getRectFromObjectProperties:properties tileMap:tileMap];
            CGPoint pos = ccp(rect.origin.x/CC_CONTENT_SCALE_FACTOR() + 80/2/CC_CONTENT_SCALE_FACTOR(), rect.origin.y/CC_CONTENT_SCALE_FACTOR() + 160/2/CC_CONTENT_SCALE_FACTOR());
            b2Vec2 vec2 = [self toMeters:pos];
            [self addNewSpriteAt:pos index:index];
            //[self drawRect:rect];
        }
        
        
        //add more blocks
//        for (int j = 0; j < 5; ++j) {
//            float x = screenSize.width * 0.5 + j * TILESIZE * 1.5;
//            for (int i = 0; i < 10; i++)
//            {
//                //[self addNewSpriteAt:CGPointMake(screenSize.width / 2, screenSize.height / 2)];
//                if (i % 2 != 0) {
//                    [self addNewSpriteAt:CGPointMake(x, (i) * (screenSize.height / 10.0))];
//                }		
//            }
//
//        }
        
        //add a ball
        float r = 20/PTM_RATIO;
        bodyDef.type = b2_dynamicBody;
        bodyDef.bullet = true;
        bodyDef.position = [self toMeters:CGPointMake(player.position.x + 80, player.position.y)];
        CCSprite* spriteBall = [CCSprite spriteWithFile:@"ball.png"];
        spriteBall.position = [self toPixels:bodyDef.position];
        [self addChild:spriteBall];
        bodyDef.userData = (__bridge void*)spriteBall;;
        //CCSprite *sprite = (__bridge CCSprite*)(bodyDef.userData);
        //sprite.color = ccc3(255, 0, 0);
        {
        CCAnimation* anim = [CCAnimation animationWithFrames:@"ball_default-hd_" frameCount:10 delay:0.1f];
		
		// run the animation by using the CCAnimate action
		CCAnimate* animate = [CCAnimate actionWithAnimation:anim];
		CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
		[spriteBall runAction:repeat];
        }
        

        
        
        b2Body *body = world->CreateBody(&bodyDef);
        g_ball = body;
        g_ball->SetActive(false);
        g_ball->SetBullet(true);
        
        b2CircleShape dynamcCircle;
        dynamcCircle.m_p = b2Vec2(0, 0); 
        dynamcCircle.m_radius = r;
        
        
        // Define the dynamic body fixture.
        b2FixtureDef fixtureDef;
        fixtureDef.shape = &dynamcCircle;	
        fixtureDef.density = 1.0f;
        fixtureDef.friction = 0.0f;
        fixtureDef.restitution = 1.0f;
        body->CreateFixture(&fixtureDef);
		
		//[self addSomeJoinedBodies:CGPointMake(screenSize.width / 4, screenSize.height - 50)];
        

        


		
		[self scheduleUpdate];
        
        srand ( time(NULL) );        
        


		
		//[KKInput sharedInput].accelerometerActive = YES;
        //[KKInput sharedInput].deviceMotionActive = YES;
        //[KKInput sharedInput].gestureSwipeEnabled = YES;
        //[KKInput sharedInput].gestureTapEnabled = YES;
        //[KKInput sharedInput].multipleTouchEnabled = YES;
	}

	return self;
}

-(void) dealloc
{
	delete contactListener;
	delete world;

#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif
}

-(void) enableBox2dDebugDrawing
{
	float debugDrawScaleFactor = 1.0f;
#if KK_PLATFORM_IOS
	debugDrawScaleFactor = [[CCDirector sharedDirector] contentScaleFactor];
#endif
	debugDrawScaleFactor *= PTM_RATIO;
	
	debugDraw = new GLESDebugDraw(debugDrawScaleFactor);
	
	if (debugDraw)
	{
		UInt32 debugDrawFlags = 0;
		debugDrawFlags += b2Draw::e_shapeBit;
		debugDrawFlags += b2Draw::e_jointBit;
		//debugDrawFlags += b2Draw::e_aabbBit;
		//debugDrawFlags += b2Draw::e_pairBit;
		//debugDrawFlags += b2Draw::e_centerOfMassBit;
		
		debugDraw->SetFlags(debugDrawFlags);
		world->SetDebugDraw(debugDraw);
	}
}

-(CCSprite*) addSpriteAt:(CGPoint)pos index:(int)i
{
	CCSpriteBatchNode* batch = (CCSpriteBatchNode*)[self getChildByTag:kTagBatchNode];
	
	//int idx = CCRANDOM_0_1() * 2;
	//int idy = CCRANDOM_0_1() * 1;
	CGRect tileRect = CGRectMake(40*i, 0, 32, 64);
	CCSprite* sprite = [CCSprite spriteWithBatchNode:batch rect:tileRect];
	sprite.position = pos;
	[batch addChild:sprite z:(640-pos.y)] ;
	
	return sprite;
}

-(void) bodyCreateFixture:(b2Body*)body
{
	// Define another box shape for our dynamic bodies.
	b2PolygonShape dynamicBox;
	float tileInMetersX = 80 / 2 / PTM_RATIO;
    float tileInMetersY = 160 / 2 /PTM_RATIO;
	dynamicBox.SetAsBox(tileInMetersX * 0.5f, tileInMetersY * 0.5f);
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.0f;
	fixtureDef.restitution = 1.0f;
	body->CreateFixture(&fixtureDef);
	
}

-(void) addSomeJoinedBodies:(CGPoint)pos
{
	// Create a body definition and set it to be a dynamic body
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	
	// position must be converted to meters
	bodyDef.position = [self toMeters:pos];
	bodyDef.position = bodyDef.position + b2Vec2(-1, -1);
	bodyDef.userData = (__bridge void*)[self addSpriteAt:pos index:0];
	b2Body* bodyA = world->CreateBody(&bodyDef);
	[self bodyCreateFixture:bodyA];
	
	bodyDef.position = [self toMeters:pos];
	bodyDef.userData = (__bridge void*)[self addSpriteAt:pos index:0];
	b2Body* bodyB = world->CreateBody(&bodyDef);
	[self bodyCreateFixture:bodyB];
	
	bodyDef.position = [self toMeters:pos];
	bodyDef.position = bodyDef.position + b2Vec2(1, 1);
	bodyDef.userData = (__bridge void*)[self addSpriteAt:pos index:0];
	b2Body* bodyC = world->CreateBody(&bodyDef);
	[self bodyCreateFixture:bodyC];
	
	b2RevoluteJointDef jointDef;
	jointDef.Initialize(bodyA, bodyB, bodyB->GetWorldCenter());
	bodyA->GetWorld()->CreateJoint(&jointDef);
	
	jointDef.Initialize(bodyB, bodyC, bodyC->GetWorldCenter());
	bodyA->GetWorld()->CreateJoint(&jointDef);
	
	// create an invisible static body to attach to
	bodyDef.type = b2_staticBody;
	bodyDef.position = [self toMeters:pos];
	b2Body* staticBody = world->CreateBody(&bodyDef);
	jointDef.Initialize(staticBody, bodyA, bodyA->GetWorldCenter());
	bodyA->GetWorld()->CreateJoint(&jointDef);
}

-(void) addNewSpriteAt:(CGPoint)pos index:(int)index
{
	// Create a body definition and set it to be a dynamic body
	b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;//b2_dynamicBody;
	
	// position must be converted to meters
	bodyDef.position = [self toMeters:pos];
	
	// assign the sprite as userdata so it's easy to get to the sprite when working with the body
	bodyDef.userData = (__bridge void*)[self addSpriteAt:pos index:index];
	b2Body* body = world->CreateBody(&bodyDef);
	
	[self bodyCreateFixture:body];
}

-(void) update:(ccTime)delta
{
	CCDirector* director = [CCDirector sharedDirector];
    static bool isPause = false; 
    
	if (director.currentPlatformIsIOS)
	{
		KKInput* input = [KKInput sharedInput];
		if (director.currentDeviceIsSimulator == NO )
		{
            //input.deviceMotionActive = TRUE;
			//KKAcceleration* acceleration = input.acceleration;
			//b2Vec2 gravity = 10.0f * b2Vec2(acceleration.rawX, acceleration.rawY);
			//world->SetGravity(gravity);
//            if (g_state == BEGIN) {
//                KKDeviceMotion* deviceMotion = input.deviceMotion;
//                double roll =  [deviceMotion roll];
//                if (roll > 0 && roll < 3.14/4) {
//                    g_plan->ApplyForceToCenter(b2Vec2(0, 80*roll));
//                }else if(roll > 3.14/4) {
//                    g_plan->ApplyForceToCenter(b2Vec2(0, -80*(roll-3.14/4)));
//                }
//
//            }
                        
//            if (acceleration.rawY > 0.5f) {
//                g_plan->ApplyForceToCenter(b2Vec2(0, 100));
//            }else{
//                 g_plan->ApplyForceToCenter(b2Vec2(0, -100));
//            }
            
		}
        
        if (input.gestureSwipeRecognizedThisFrame) {
            if (g_state == INIT && input.gestureSwipeDirection == KKSwipeGestureDirectionRight) {

            }
            
            if (g_state == BEGIN && input.gestureSwipeDirection == KKSwipeGestureDirectionUp) {
                //g_plan->ApplyForceToCenter(b2Vec2(0, 500));
            }
            
            if (g_state == BEGIN && input.gestureSwipeDirection == KKSwipeGestureDirectionDown) {
                //g_plan->ApplyForceToCenter(b2Vec2(0, -500));
            }
        }
        
//        static CGPoint beginPos = CGPointZero;
//        static bool   beginTouch = false;
//        static float32 planBeginPos = 0;
//
//        
//        if (input.anyTouchBeganThisFrame && g_state == BEGIN) {
//            beginPos = [input locationOfAnyTouchInPhase:KKTouchPhaseBegan];
//            planBeginPos = g_plan->GetPosition().y;
//            beginTouch = true;
//        }
//        
//        if (beginTouch) {
//            CGPoint curPos = [input locationOfAnyTouchInPhase:KKTouchPhaseMoved];
//            if (curPos.x != 0 && curPos.y != 0) 
//            {
//                float32 moveDistance = curPos.y - beginPos.y;
//                //float32 x = g_plan->GetPosition().x;
//                //float32 planNowPos = planBeginPos + moveDistance/CC_CONTENT_SCALE_FACTOR()/PTM_RATIO;
//                //g_plan->SetTransform(b2Vec2(x, planNowPos), g_plan->GetAngle());
//                g_plan->ApplyForceToCenter(b2Vec2(0, moveDistance*10));
//            }
//        }
//        
//        if (input.anyTouchEndedThisFrame) {
//            beginPos = CGPointZero;
//            beginTouch = false;
//            planBeginPos = 0;
//            
//        }
        
        b2Vec2 vec = g_ball->GetLinearVelocity();
        float32 len = vec.Normalize();

        
        if (len > 10) {
            vec *= 10;
            g_ball->SetLinearVelocity(vec);
        }
        
        
        vec = g_ball->GetPosition();
        if (vec.x > 480/PTM_RATIO) {
            vec.x = (480-10)/PTM_RATIO;
        }else if(vec.x < 0){
            vec.x = 0;
            
        }
        
        if (vec.y > 320/PTM_RATIO) {
            vec.y = (320-10)/PTM_RATIO;
        }else if(vec.y < 0){
            vec.y = 0;
        }
        
        g_ball->SetTransform(vec, g_ball->GetAngle());
        

        if (g_state == BEGIN) {
            g_ball->ApplyForceToCenter( b2Vec2(rand()%10*0.1, rand()%10*0.1) );
        }


        float32 speed = 0;
        
        old = g_plan->GetPosition().y*PTM_RATIO;
        if (newPos == -1) {
            newPos = old;
        }

        
        old = g_plan->GetPosition().y*PTM_RATIO;
        if (newPos == -1) {
            newPos = old;
        }
        
                
        if (tap && newPos != old) {
            speed = -(newPos - old)/PTM_RATIO*10;
            
        }   
        if (abs(speed) > 1) {
            //joint->EnableMotor(true);
            joint->SetMotorSpeed(speed);
        }else{
            //joint->EnableMotor(false);
             joint->SetMotorSpeed(0);
            tap = false;
            speed = 0;
            newPos = old;
        }
                
        /*

		if (input.anyTouchEndedThisFrame)
		{
			//[self addNewSpriteAt:[input locationOfAnyTouchInPhase:KKTouchPhaseEnded]];
            CGSize screenSize = [CCDirector sharedDirector].winSize;
            //float widthInMeters = screenSize.width / PTM_RATIO;
            //float heightInMeters = screenSize.height / PTM_RATIO;
            CGPoint p = [input locationOfAnyTouchInPhase:KKTouchPhaseEnded];
            if ( g_state == INIT && p.x > screenSize.width/2 ) {
                g_ball->ApplyForceToCenter(b2Vec2(1000, 0));
                g_state = BEGIN;
            }
            
            if ( g_state == BEGIN && p.x < screenSize.width/2 ) {
                b2Vec2 vec =  g_plan->GetPosition();
                CGPoint point = [self toPixels:vec];
                if (p.y > point.y) {
                    g_plan->ApplyForceToCenter(b2Vec2(0, 200));
                }else{
                    g_plan->ApplyForceToCenter(b2Vec2(0, -200));
                }
                //g_state = BEGIN;
            }
            
		}
         */
	}
	else if (director.currentPlatformIsMac)
	{
		KKInput* input = [KKInput sharedInput];
		if (input.isAnyMouseButtonUpThisFrame || CGPointEqualToPoint(input.scrollWheelDelta, CGPointZero) == NO)
		{
			//[self addNewSpriteAt:input.mouseLocation];
		}
	}
    
    
    // Sort the nuke array to group duplicates.
    std::sort(g_list.data(), g_list.data() + g_list.size());
    
    // Destroy the bodies, skipping duplicates.
    uint32 i = 0;
    while (i < g_list.size())
    {
        b2Body* b = g_list[i++];
        while (i <  g_list.size() && g_list[i] == b)
        {
            ++i;
        }
        
        {
            CCSprite* sprite = (__bridge CCSprite*)b->GetUserData();

            
            CCParticleSystem* system;

            system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"fx-explosion2.plist"];
            [[SimpleAudioEngine sharedEngine] playEffect:@"explo1.wav" pitch:1.0f pan:0.0f gain:1.0f];

            system.positionType = kCCPositionTypeFree;
            system.autoRemoveOnFinish = YES;
            system.position = sprite.position;
            
            // Add the particle effect to the GameScene, for these reasons:
            // - self is a sprite added to a spritebatch and will only allow CCSprite nodes (it crashes if you try)
            // - self is now invisible which might affect rendering of the particle effect
            // - since the particle effects are short lived, there is no harm done by adding them directly to the GameScene
            [self addChild:system];
             
             CCSpriteBatchNode* batch = (CCSpriteBatchNode*)[self getChildByTag:kTagBatchNode];
             [batch removeChild:sprite cleanup:false];
             g_world->DestroyBody(b);
            
        }
    }
    
    g_list.clear();
    
    
    
    
	// The number of iterations influence the accuracy of the physics simulation. With higher values the
	// body's velocity and position are more accurately tracked but at the cost of speed.
	// Usually for games only 1 position iteration is necessary to achieve good results.
	//float timeStep = 1/60.0;//0.03f;
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	if(isPause) return;
    world->Step(delta, velocityIterations, positionIterations);
    
	// for each body, get its assigned sprite and update the sprite's position
	for (b2Body* body = world->GetBodyList(); body != nil; body = body->GetNext())
	{
		CCSprite* sprite = (__bridge CCSprite*)body->GetUserData();
		if (sprite != NULL)
		{
			// update the sprite's position to where their physics bodies are
			sprite.position = [self toPixels:body->GetPosition()];
			float angle = body->GetAngle();
			sprite.rotation = CC_RADIANS_TO_DEGREES(angle) * -1;
        }
	}
}

//- (void)movePlan:(int)i
//{
//    if (g_state == BEGIN) {
//        //KKDeviceMotion* deviceMotion = input.deviceMotion;
//        //double roll =  [deviceMotion roll];
//        if (i > 0 ) {
//            g_plan->ApplyForceToCenter(b2Vec2(0, 1.5*i));
//        }else {
//            g_plan->ApplyForceToCenter(b2Vec2(0, 1.5*i));
//        }
//        
//    }
//
//    
//}

CGPoint g_beginPos; 
CGPoint g_movePos; 
CGPoint g_endPos;

-(void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent *)event
{
    CGPoint p = [self convertTouchToNodeSpace:touch];	
    NSLog(@"ccTouchMoved: x = %f, y = %f", p.x, p.y);
//    if (p.x != 0 && p.y != 0)
//    {
//        if (g_state == BEGIN) {
//            
//            //CGPoint p = input.gestureTapLocation;
//            g_movePos = p;
//        }
//        
//        tap = true;
//        
//        
//    }

}



-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent *)event
{	
    CGPoint p = [self convertTouchToNodeSpace:touch];	
    NSLog(@"ccTouchBegin: x = %f, y = %f", p.x, p.y);
    g_beginPos = p;
    
	if (g_state != BEGIN){
        
        g_state = BEGIN;

        
    }
    
    return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint p = [self convertTouchToNodeSpace:touch];
	NSLog(@"ccTouchended: x = %f, y = %f", p.x, p.y);
   //if (tap == true) {
        g_endPos = p;
        CGPoint vec = ccpSub(g_beginPos, g_endPos);
        b2Vec2 b = b2Vec2(vec.x, vec.y);
        b.Normalize();
        b *= 1000;
       
       NSLog(@"apply a force: x = %f, y = %f", b.x, b.y);
       
               g_ball->SetActive(true);

        g_ball->ApplyForceToCenter(b);

        
  // }
    
    tap = false;
    
}


// convenience method to convert a CGPoint to a b2Vec2
-(b2Vec2) toMeters:(CGPoint)point
{
	return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

// convenience method to convert a b2Vec2 to a CGPoint
-(CGPoint) toPixels:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}


#if DEBUG
-(void) draw
{
	[super draw];

	if (debugDraw)
	{
		// these GL states must be disabled/enabled otherwise drawing debug data will not render and may even crash
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glEnableClientState(GL_VERTEX_ARRAY);
		
		world->DrawDebugData();
		
		glDisableClientState(GL_VERTEX_ARRAY);   
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glEnableClientState(GL_COLOR_ARRAY);
		glEnable(GL_TEXTURE_2D);	
	}
}
#endif

@end
