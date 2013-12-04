//
//  AppDelegate.h
//  Counterpoint
//
//  Created by Becky on 12/2/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PreferencesWindowController;
@class GoogleMusicAPI;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSToolbarDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet NSToolbar* toolbar;

@property (nonatomic, strong) IBOutlet NSTableView* localTable;
@property (nonatomic, strong) IBOutlet NSTableView* spotifyTable;

@property (nonatomic, strong) PreferencesWindowController* preferencesWindowController;

@property (nonatomic, strong) IBOutlet NSTableView* googleTable;
@property (nonatomic, strong) GoogleMusicAPI* googleMusicAPI;
@property (nonatomic, strong) IBOutlet NSArrayController* googleArrayController;


-(IBAction)play:(id)sender;
-(IBAction)showPreferences:(id)sender;

@end
