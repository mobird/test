//
//  HealthbarComponent.m
//  ShootEmUp
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

#import "HealthbarComponent.h"
#import "EnemyEntity.h"

@implementation HealthbarComponent

-(id) init
{
	if ((self = [super init]))
	{
		self.visible = NO;
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) reset
{
	float parentHeight = self.parent.contentSize.height;
	float selfHeight = self.contentSize.height;
	self.position = CGPointMake(self.parent.anchorPointInPixels.x, parentHeight + selfHeight);
	self.scaleX = 1;
	self.visible = YES;
}

-(void) update:(ccTime)delta
{
	if (self.parent.visible)
	{
		NSAssert([self.parent isKindOfClass:[EnemyEntity class]], @"not a EnemyEntity");
		EnemyEntity* parentEntity = (EnemyEntity*)self.parent;
		self.scaleX = parentEntity.hitPoints / (float)parentEntity.initialHitPoints;
	}
	else if (self.visible)
	{
		self.visible = NO;
	}
}

@end
