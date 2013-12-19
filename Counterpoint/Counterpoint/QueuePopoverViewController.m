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

-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		NSLog(@"AppDelegate is : %@", [self appDelegate]);
	}
	return self;
}

-(void)awakeFromNib
{
	NSLog(@"AppDelegate is : %@", [self appDelegate]);
	NSLog(@"Array Controller is : %@", [[self appDelegate] queueArrayController]);
}

-(void)popoverWillShow:(NSNotification *)notification
{
	NSLog(@"AppDelegate is : %@", [self appDelegate]);
	NSLog(@"Array Controller is : %@", [[self appDelegate] queueArrayController]);
}

@end
