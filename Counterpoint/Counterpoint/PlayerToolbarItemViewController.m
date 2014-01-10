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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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

-(IBAction)pause:(id)sender
{
	[[self appDelegate] pause:self];
}

-(IBAction)next:(id)sender
{
	[[self appDelegate] next:self];
}

@end
