//
//  PlayerToolbarItem.m
//  Counterpoint
//
//  Created by Becky on 12/20/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import "PlayerToolbarItem.h"
#import "PlayerToolbarItemViewController.h"

@implementation PlayerToolbarItem

-(id)initWithItemIdentifier:(NSString *)itemIdentifier
{
	self = [super initWithItemIdentifier:itemIdentifier];
	if (self)
	{
		_viewController = [[PlayerToolbarItemViewController alloc] init];
		[self setView:[_viewController view]];
		[self setMinSize:[_viewController view].bounds.size];
		[self setMaxSize:[_viewController view].bounds.size];
    }
    return self;
}

@end
