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

@interface AppDelegate : NSObject <NSApplicationDelegate, NSToolbarDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet NSToolbar* toolbar;

@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) AVPlayerItem* playerItem;

@property (nonatomic, strong) IBOutlet NSTabView* tabView;

@property (nonatomic, strong) IBOutlet NSTableView* localTable;
@property (nonatomic, strong) IBOutlet NSTableView* spotifyTable;

@property (nonatomic, strong) PreferencesWindowController* preferencesWindowController;

@property (nonatomic, strong) IBOutlet NSTableView* googleTable;
@property (nonatomic, strong) GoogleMusicController* googleMusicController;
@property (nonatomic, strong) IBOutlet NSArrayController* googleArrayController;


-(IBAction)play:(id)sender;
-(IBAction)showPreferences:(id)sender;

@end
