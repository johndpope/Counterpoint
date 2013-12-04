//
//  AppDelegate.m
//  Counterpoint
//
//  Created by Becky on 12/2/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import "AppDelegate.h"
#import "PreferencesWindowController.h"
#import "GoogleMusicAPI.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[self setPreferencesWindowController:[[PreferencesWindowController alloc] init]];
	[self loadGoogleTable];
}

-(IBAction)play:(id)sender
{
	;
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

-(void)loadGoogleTable
{
	[self setGoogleMusicAPI:[[GoogleMusicAPI alloc] init]];
	BOOL loggedIn = [[self googleMusicAPI] loginWithUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"googleUsername"] withPassword:[[NSUserDefaults standardUserDefaults] objectForKey:@"googlePassword"]];
	if (!loggedIn)
		; //ALERT!
//	NSMutableArray* songsArray = [[self googleMusicAPI] getAllSongs];
//	[[self googleArrayController] setContent:songsArray];
}

@end
