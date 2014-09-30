//
//  PlayerToolbarItemViewController.m
//  Counterpoint
//
//  Created by Becky on 12/20/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import "PlayerToolbarItemViewController.h"
#import "AppDelegate.h"

@interface PlayerToolbarItemViewController ()

@end

@implementation PlayerToolbarItemViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"PlayerToolbarItemViewController" bundle:nibBundleOrNil];
    if (self)
	{
		_appDelegate = [NSApp delegate];
    }
    return self;
}

-(IBAction)play:(id)sender
{
	if ([sender state] == NSOnState)
		[[self appDelegate] pause:self];
	else
		[[self appDelegate] play:self];
}

-(IBAction)next:(id)sender
{
	[[self appDelegate] next:self];
}

-(IBAction)adjustVolume:(NSSlider*)sender
{
	[[[self appDelegate] player] setVolume:[sender floatValue]];
}

@end
