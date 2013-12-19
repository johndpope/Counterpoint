//
//  QueuePopoverViewController.m
//  Counterpoint
//
//  Created by Becky on 12/18/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import "QueuePopoverViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface QueuePopoverViewController ()

@end

@implementation QueuePopoverViewController

-(void)awakeFromNib
{
	[[NSApp delegate] addObserver:self forKeyPath:@"player" options:0 context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"items"])
	{
		[[self queueArrayController] setContent:object];
	}
	if ([keyPath isEqualToString:@"player"])
	{
		[[[NSApp delegate] player] addObserver:self forKeyPath:@"items" options:0 context:nil];
	}
}

-(void)dealloc
{
	[self removeObserver:self forKeyPath:@"player"];
	[self removeObserver:self forKeyPath:@"items"];
}

@end
