//
//  CurrentTrackToolbarItemViewController.m
//  Counterpoint
//
//  Created by Becky on 1/10/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import "CurrentTrackToolbarItemViewController.h"
#import "AppDelegate.h"

@interface CurrentTrackToolbarItemViewController ()

@end

@implementation CurrentTrackToolbarItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"CurrentTrackToolbarItemViewController" bundle:nibBundleOrNil];
    if (self)
	{
		_appDelegate = [NSApp delegate];
    }
    return self;
}

@end
