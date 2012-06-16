/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "ContactListener.h"
#import "cocos2d.h"
#import <vector>

extern b2Body *g_ball;
extern b2Body *g_plan;
extern b2World* g_world;
extern std::vector<b2Body *> g_list;

void ContactListener::BeginContact(b2Contact* contact)
{
	b2Body* bodyA = contact->GetFixtureA()->GetBody();
	b2Body* bodyB = contact->GetFixtureB()->GetBody();
	CCSprite* spriteA = (__bridge CCSprite*)bodyA->GetUserData();
	CCSprite* spriteB = (__bridge CCSprite*)bodyB->GetUserData();
    
//    if (bodyA != g_ball && bodyA != g_plan) {
//        //g_world->DestroyBody(bodyA);// bodyA;
//        g_list.push_back(bodyA);
//        
//    }
//    
//    if (bodyB != g_ball && bodyB != g_plan) {
//        //g_world->DestroyBody(bodyA);// bodyA;
//        g_list.push_back(bodyB);
//        
//    }
    
    //b2Vec2 pos = g_ball->GetWorldCenter();
    //b2Vec2 speed = g_ball->GetLinearVelocityFromWorldPoint(pos);
    
    //g_ball->SetLinearVelocity(speed + speed);
	
	if (spriteA != NULL && spriteB != NULL)
	{
		//spriteA.color = ccMAGENTA;
		//spriteB.color = ccMAGENTA;
        
	}
}

void ContactListener::EndContact(b2Contact* contact)
{
	b2Body* bodyA = contact->GetFixtureA()->GetBody();
	b2Body* bodyB = contact->GetFixtureB()->GetBody();
	CCSprite* spriteA = (__bridge CCSprite*)bodyA->GetUserData();
	CCSprite* spriteB = (__bridge CCSprite*)bodyB->GetUserData();
    
    if (bodyA != g_ball && bodyA != g_plan && bodyA->GetUserData()) {
        //g_world->DestroyBody(bodyA);// bodyA;
        g_list.push_back(bodyA);
        
    }
    
    if (bodyB != g_ball && bodyB != g_plan && bodyB->GetUserData()) {
        //g_world->DestroyBody(bodyA);// bodyA;
        g_list.push_back(bodyB);
        
    }


    
	
	if (spriteA != NULL && spriteB != NULL)
	{
		spriteA.color = ccWHITE;
		spriteB.color = ccWHITE;
//        if (<#condition#>) {
//            <#statements#>
//        }
	}
}
