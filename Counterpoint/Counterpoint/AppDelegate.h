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
@class LastFMController;
@class SoundCloudController;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSToolbarDelegate, NSTabViewDelegate, NSOutlineViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSToolbar* toolbar;
@property (assign) IBOutlet NSOutlineView* sidebar;
@property (assign) IBOutlet NSTreeController* sidebarController;

@property (assign) CurrentTrackToolbarItem* currentTrackToolbarItem;
@property (assign) PlayerToolbarItem* playerToolbarItem;

@property (assign) IBOutlet NSTableView* table;
@property (assign) IBOutlet NSTextField* songCountLabel;
@property (assign) IBOutlet NSSearchField* searchField;

@property (nonatomic, retain) NSMutableArray* sidebarItemsArray;

@property (nonatomic, strong) IBOutlet NSArrayController* queueArrayController;

@property (nonatomic, strong) AVQueuePlayer* player;
@property (nonatomic, strong) CPTrack* currentTrack;
@property (nonatomic, strong) id playerTimeObserverReturnValue;

@property (nonatomic, strong) GoogleMusicController* googleMusicController;
@property (nonatomic, strong) LastFMController* lastFmController;
@property (nonatomic, strong) SoundCloudController* soundCloudController;

@property (nonatomic, strong) NSMutableArray* tracksArray;
@property (assign) IBOutlet NSArrayController* tracksArrayController;

@property (nonatomic, strong) NSMutableArray* playlistsArray;

@property (nonatomic, strong) PreferencesWindowController* preferencesWindowController;

-(void)play:(id)sender;
-(void)pause:(id)sender;
-(void)next:(id)sender;
-(void)shuffle:(id)sender;

-(void)finishedLoadingTracks;

-(void)clickedToQueueItemAtIndex:(NSInteger)queueIndex;

@end
