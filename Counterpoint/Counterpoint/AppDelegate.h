//
//  AppDelegate.h
//  Counterpoint
//
//  Created by Becky on 12/2/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@class PreferencesWindowController;
@class GoogleMusicController;
@class CPTrack;
@class QueuePopoverViewController;
@class CurrentTrackToolbarItem;
@class PlayerToolbarItem;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSToolbarDelegate, NSTabViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet NSToolbar* toolbar;

@property (nonatomic, strong) CurrentTrackToolbarItem* currentTrackToolbarItem;
@property (nonatomic, strong) PlayerToolbarItem* playerToolbarItem;

@property (nonatomic, strong) IBOutlet NSTableView* table;
@property (nonatomic, strong) IBOutlet NSTextField* songCountLabel;

@property (nonatomic, strong) IBOutlet NSArrayController* queueArrayController;

@property (nonatomic, strong) AVQueuePlayer* player;
@property (nonatomic, strong) CPTrack* currentTrack;
@property (nonatomic, strong) id playerTimeObserverReturnValue;

@property (nonatomic, strong) GoogleMusicController* googleMusicController;

@property (nonatomic, strong) NSMutableArray* tracksArray;
@property (nonatomic, strong) IBOutlet NSArrayController* tracksArrayController;

@property (nonatomic, strong) PreferencesWindowController* preferencesWindowController;

-(void)play:(id)sender;
-(void)pause:(id)sender;
-(void)next:(id)sender;
-(void)shuffle:(id)sender;

-(void)clickedToQueueItemAtIndex:(NSInteger)queueIndex;

@end
