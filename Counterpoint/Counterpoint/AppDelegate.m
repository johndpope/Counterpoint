//
//  AppDelegate.m
//  Counterpoint
//
//  Created by Becky on 12/2/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import "AppDelegate.h"
#import "PreferencesWindowController.h"
#import "GoogleTableController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[self setPreferencesWindowController:[[PreferencesWindowController alloc] init]];
	
	[self setGoogleTableController:[[GoogleTableController alloc] init]];
	[[[self tabView] tabViewItemAtIndex:1] setView:[[self googleTableController] view]];
	[[self googleTableController] populateGoogleTable];
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
	[[self window] setIsVisible:YES];
	return YES;
}

#pragma mark - Player

-(IBAction)pause:(id)sender
{
	[[self player] pause];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[[self player] play];
}

-(IBAction)play:(id)sender
{
	NSTabViewItem* selectedTabView = [[self tabView] selectedTabViewItem];
	if ([[selectedTabView label] isEqualToString:@"Google Music"])
	{
		AVPlayerItem* googlePlayerItem = [[self googleTableController] getPlayerItemForSelectedSong];
		
		[self setPlayerItem:googlePlayerItem];
		[[self playerItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
		[self setPlayer:[AVPlayer playerWithPlayerItem:[self playerItem]]];
	}
}

-(IBAction)reload:(id)sender
{
	NSTabViewItem* selectedTabView = [[self tabView] selectedTabViewItem];
	if ([[selectedTabView label] isEqualToString:@"Google Music"])
	{
		[[self googleTableController] populateGoogleTable];
	}
}

#pragma mark - Preferences

-(IBAction)showPreferences:(id)sender
{
	[[self preferencesWindowController] showWindow:self];
}

@end
