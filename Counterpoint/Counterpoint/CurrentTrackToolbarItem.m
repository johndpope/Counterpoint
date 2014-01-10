//
//  CurrentTrackToolbarItem.m
//  Counterpoint
//
//  Created by Becky on 1/10/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import "CurrentTrackToolbarItem.h"
#import "CurrentTrackToolbarItemViewController.h"

@implementation CurrentTrackToolbarItem

-(id)initWithItemIdentifier:(NSString *)itemIdentifier
{
	self = [super initWithItemIdentifier:itemIdentifier];
	if (self)
	{
		_viewController = [[CurrentTrackToolbarItemViewController alloc] init];
		[self setMinSize:[_viewController view].bounds.size];
		[self setMaxSize:[_viewController view].bounds.size];
		[self setView:[_viewController view]];
		[self setEnabled:YES];
    }
    return self;
}


@end
