//
//  PlayerEtity.m
//  Flipshot
//
//  Created by cui yong on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayerEtity.h"
#import "cocos2d.h"


@interface PlayerEtity (PrivateMethods)
-(id) initWithShipImage;
@end


@implementation PlayerEtity

+(id) ship
{
	return [[self alloc] initWithShipImage] ;//autorelease];
}

-(id) initWithShipImage
{
	// Loading the Ship's sprite using a sprite frame name (eg the filename)
	if ((self = [super initWithSpriteFrameName:@"player.png"]))
	{

	}
	return self;
}



@end
