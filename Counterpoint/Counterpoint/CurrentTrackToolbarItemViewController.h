//
//  CurrentTrackToolbarItemViewController.h
//  Counterpoint
//
//  Created by Becky on 1/10/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppDelegate;
@class QueuePopoverViewController;

@interface CurrentTrackToolbarItemViewController : NSViewController

@property (nonatomic, weak) IBOutlet AppDelegate* appDelegate;
@property (nonatomic, assign) IBOutlet NSSlider* durationSlider;
@property (nonatomic, assign) IBOutlet NSTextField* durationLabel;
@property (nonatomic, assign) IBOutlet NSTextField* currentTimeLabel;
@property (nonatomic, strong) id playerTimeObserverReturnValue;

@property (nonatomic, strong) IBOutlet NSPopover* queuePopover;
@property (assign) IBOutlet QueuePopoverViewController* queuePopoverViewController;
@property (assign) IBOutlet NSButton* queueButton;

@property (assign) IBOutlet NSButton* shuffleButton;

-(void)setupTrackDurationSlider;

@end
