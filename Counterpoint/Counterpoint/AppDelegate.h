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
@class GoogleTableController;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSToolbarDelegate, NSTabViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet NSToolbar* toolbar;
@property (nonatomic, strong) IBOutlet NSToolbarItem* queueToolbarItem;

@property (nonatomic, strong) AVQueuePlayer* player;
@property (nonatomic, strong) AVPlayerItem* playerItem;
@property (nonatomic, strong) NSString* currentlyPlayingSongTitle;

@property (nonatomic, strong) IBOutlet NSPopover* queuePopover;
@property (nonatomic, strong) IBOutlet NSArrayController* queueArrayController;

@property (nonatomic, strong) IBOutlet NSView* view;

@property (nonatomic, strong) IBOutlet NSTableView* localTable;
@property (nonatomic, strong) IBOutlet NSTableView* spotifyTable;
@property (nonatomic, strong) IBOutlet GoogleTableController* googleTableController;

@property (nonatomic, strong) PreferencesWindowController* preferencesWindowController;

-(void)startPlayingPlayerItem:(AVPlayerItem*)playerItem withQueueBuildingCompletionHandler:(void(^)(void))completionHandler;
-(void)addItem:(NSDictionary*)trackDict toQueue:(AVPlayerItem*)playerItem;

-(IBAction)play:(id)sender;
-(IBAction)pause:(id)sender;
-(IBAction)next:(id)sender;

@end
