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

@interface AppDelegate : NSObject <NSApplicationDelegate, NSToolbarDelegate, NSTabViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet NSToolbar* toolbar;
@property (nonatomic, strong) IBOutlet NSTableView* table;
@property (nonatomic, strong) IBOutlet NSTextField* songCountLabel;

@property (nonatomic, strong) IBOutlet NSToolbarItem* queueToolbarItem;
@property (nonatomic, strong) IBOutlet NSPopover* queuePopover;
@property (nonatomic, strong) IBOutlet NSArrayController* queueArrayController;

@property (nonatomic, strong) AVQueuePlayer* player;
@property (nonatomic, strong) CPTrack* currentTrack;

@property (nonatomic, strong) GoogleMusicController* googleMusicController;

@property (nonatomic, strong) NSMutableArray* tracksArray;
@property (nonatomic, strong) IBOutlet NSArrayController* tracksArrayController;

@property (nonatomic, strong) PreferencesWindowController* preferencesWindowController;


-(void)startPlayingPlayerItem:(AVPlayerItem*)playerItem withQueueBuildingCompletionHandler:(void(^)(void))completionHandler;
-(void)addItem:(NSDictionary*)trackDict toQueue:(AVPlayerItem*)playerItem;
-(IBAction)play:(id)sender;
-(IBAction)pause:(id)sender;
-(IBAction)next:(id)sender;

@end
