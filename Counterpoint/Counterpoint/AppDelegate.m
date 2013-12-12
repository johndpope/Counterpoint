//
//  AppDelegate.m
//  Counterpoint
//
//  Created by Becky on 12/2/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import "AppDelegate.h"
#import "PreferencesWindowController.h"
#import "GoogleMusicController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[self setPreferencesWindowController:[[PreferencesWindowController alloc] init]];
	[self populateGoogleTable];
}

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
		NSInteger selectedRow = [[self googleTable] selectedRow];
		NSDictionary* songDictionary = [[[self googleArrayController] arrangedObjects] objectAtIndex:selectedRow];
		NSString* songId = [songDictionary objectForKey:@"id"];
		NSString* streamURLString = [[self googleMusicController] getStreamUrl:songId];
		NSURL* streamURL = [[NSURL alloc] initWithString:streamURLString];
		
		[self setPlayerItem:[AVPlayerItem playerItemWithURL:streamURL]];
		[[self playerItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
		[self setPlayer:[AVPlayer playerWithPlayerItem:[self playerItem]]];
	}
}

-(IBAction)showPreferences:(id)sender
{
	[[self preferencesWindowController] showWindow:self];
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
	[[self window] setIsVisible:YES];
	return YES;
}

-(void)loadGoogleTracks
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[self googleArrayController] setContent:[[self googleMusicController] songArray]];
}

-(void)populateGoogleTable
{
	if (![self googleMusicController])
		[self setGoogleMusicController:[[GoogleMusicController alloc] init]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadGoogleTracks) name:@"GoogleMusicTracksLoaded" object:nil];
	
	[[self googleMusicController] loginWithUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"googleUsername"] password:[[NSUserDefaults standardUserDefaults] objectForKey:@"googlePassword"]];
}

@end
