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
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(IBAction)play:(id)sender
{
	[(AppDelegate*)[NSApp delegate] play:self];
}

-(IBAction)pause:(id)sender
{
	[(AppDelegate*)[NSApp delegate] pause:self];
}

-(IBAction)next:(id)sender
{
	[(AppDelegate*)[NSApp delegate] next:self];
}

@end
