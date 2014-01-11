//
//  CurrentTrackToolbarItemViewController.h
//  Counterpoint
//
//  Created by Becky on 1/10/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppDelegate;

@interface CurrentTrackToolbarItemViewController : NSViewController

@property (nonatomic, weak) IBOutlet AppDelegate* appDelegate;
@property (nonatomic, assign) IBOutlet NSSlider* durationSlider;

@end
