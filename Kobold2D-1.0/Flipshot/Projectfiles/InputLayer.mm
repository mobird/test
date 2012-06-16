//
//  InputLayer.m
//  ScrollingWithJoy
//
//  Created by Steffen Itterheim on 04.08.10.
//
//  Updated by Andreas Loew on 20.06.11:
//  * retina display
//  * framerate independency
//  * using TexturePacker http://www.texturepacker.com
//
//  Copyright Steffen Itterheim and Andreas Loew 2010-2011. 
//  All rights reserved.
//

#import "InputLayer.h"
#import "GameScene.h"
#import "PhysicsLayer.h"

#import "SimpleAudioEngine.h"

@interface InputLayer (PrivateMethods)
-(void) addFireButton;
-(void) addJoystick;
@end

@implementation InputLayer

-(id) init
{
	if ((self = [super init]))
	{
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        float sw = screenSize.width;
		float sh = screenSize.height;
		//[self addFireButton];
		//[self addJoystick];
        
#define UP 10
        
        
        CCLabelTTF* label = [CCLabelTTF labelWithString:@"score:xxx" fontName:@"Marker Felt" fontSize:32];
        [self addChild:label];
        [label setColor:ccc3(222, 0, 0)];
        label.position = CGPointMake(screenSize.width / 2, screenSize.height - UP);
        
        CCLabelTTF* lifeLabel = [CCLabelTTF labelWithString:@"life:xxx" fontName:@"Marker Felt" fontSize:32];
        [self addChild:lifeLabel];
        [lifeLabel setColor:ccc3(222, 0, 0)];
        lifeLabel.position = CGPointMake(50, screenSize.height - UP);
        
        // menu button
		menuButton = [CCLabelTTF labelWithString:@"pause" fontName:@"Marker Felt" fontSize:32];

		menuButton.position = ccp(sw-60,sh-UP);  
        [menuButton setColor:ccc3(222, 0, 0)];
        [self addChild:menuButton];
		
		[self scheduleUpdate];
	}
	
	return self;
}

//-(void) dealloc
//{
//	[super dealloc];
//}

-(void) addFireButton
{
	float buttonRadius = 50;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];

	fireButton = [SneakyButton button];
	fireButton.isHoldable = YES;
	
	SneakyButtonSkinnedBase* skinFireButton = [SneakyButtonSkinnedBase skinnedButton];
	skinFireButton.position = CGPointMake(screenSize.width - buttonRadius * 1.5f, buttonRadius * 1.5f);
    skinFireButton.defaultSprite = [CCSprite spriteWithSpriteFrameName:@"fire-button-idle.png"];
    skinFireButton.pressSprite = [CCSprite spriteWithSpriteFrameName:@"fire-button-pressed.png"];
	skinFireButton.button = fireButton;
	[self addChild:skinFireButton];

}

-(void) addJoystick
{
	float stickRadius = 50;

	joystick = [SneakyJoystick joystickWithRect:CGRectMake(0, 0, stickRadius, stickRadius)];
	joystick.autoCenter = YES;
	
	// Now with fewer directions
	joystick.isDPad = YES;
	joystick.numberOfDirections = 8;
	
	SneakyJoystickSkinnedBase* skinStick = [SneakyJoystickSkinnedBase skinnedJoystick];
	skinStick.position = CGPointMake(stickRadius * 1.5f, stickRadius * 1.5f);
    skinStick.backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"joystick-back.png"];
	skinStick.thumbSprite = [CCSprite spriteWithSpriteFrameName:@"joystick-stick.png"];
	skinStick.joystick = joystick;
	[self addChild:skinStick];
}

-(void) update:(ccTime)delta
{
	totalTime += delta;
    
    
    GameScene* game = [GameScene sharedGameScene];
    PhysicsLayer *p = (PhysicsLayer*)([game getChildByTag:GameSceneLayerTagPhysics]);


	// Continuous fire
	if (fireButton.active && totalTime > nextShotTime)
	{
		nextShotTime = totalTime + 0.3f;
        
//		ShipEntity* ship = [game defaultShip];
//		BulletCache* bulletCache = [game bulletCache];
//
//		// Set the position, velocity and spriteframe before shooting
//		CGPoint shotPos = CGPointMake(ship.position.x + 45, ship.position.y - 19);
//        
//		float spread = (CCRANDOM_0_1() - 0.5f) * 0.5f;
//		CGPoint velocity = CGPointMake(200, spread * 50);
//		[bulletCache shootBulletFrom:shotPos velocity:velocity frameName:@"bullet.png" isPlayerBullet:YES];
        
		
		float pitch = CCRANDOM_0_1() * 0.2f + 0.9f;
		[[SimpleAudioEngine sharedEngine] playEffect:@"shoot1.wav" pitch:pitch pan:0.0f gain:1.0f];
	}
	
	// Allow faster shooting by quickly tapping the fire button.
	if (fireButton.active == NO)
	{
		nextShotTime = 0;
	}
    
//    CGPoint velocity = ccpMult(joystick.velocity, 7000 * delta);
//    if (velocity.x != 0 && velocity.y != 0)
//    {
//        [p movePlan:velocity.y]; 
//    }
	
	// Moving the ship with the thumbstick.
	//GameScene* game = [GameScene sharedGameScene];
//	ShipEntity* ship = [game defaultShip];
//	
//	CGPoint velocity = ccpMult(joystick.velocity, 7000 * delta);
//	if (velocity.x != 0 && velocity.y != 0)
//	{
//		ship.position = CGPointMake(ship.position.x + velocity.x * delta, ship.position.y + velocity.y * delta);
//	}
}

@end
