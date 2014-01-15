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
	[[self queueTableView] setDoubleAction:@selector(doubleClick:)];
}

-(void)doubleClick:(id)sender
{
	[[self appDelegate] clickedToQueueItemAtIndex:[[self queueTableView] clickedRow]];
}

@end
