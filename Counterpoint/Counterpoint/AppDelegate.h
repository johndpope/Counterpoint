//
//  AppDelegate.h
//  Counterpoint
//
//  Created by Becky on 12/2/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

/*
	AppDelegate has a few main "parts":
		Main Window
			Player 
				Current song
				Queue of songs
				Player controls
			Current pool of available songs (from Google Music, local library, etc)
		Preferences
*/



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

@property (nonatomic, strong) IBOutlet NSPopover* queuePopover;

@property (nonatomic, strong) IBOutlet NSTabView* tabView;

@property (nonatomic, strong) IBOutlet NSTableView* localTable;
@property (nonatomic, strong) IBOutlet NSTableView* spotifyTable;
@property (nonatomic, strong) IBOutlet GoogleTableController* googleTableController;

@property (nonatomic, strong) PreferencesWindowController* preferencesWindowController;

-(void)playWithPlayerItemQueue:(NSArray*)playerItemQueue;

@end
