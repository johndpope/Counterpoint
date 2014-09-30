//
//  PreferencesViewController.m
//  Counterpoint
//
//  Created by Becky on 12/2/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "AppDelegate.h"
#import "GoogleMusicController.h"
#import "LastFMController.h"
#import "SoundCloudController.h"

@interface PreferencesWindowController ()

@property (nonatomic, strong) IBOutlet NSTextField* googleUsername;
@property (nonatomic, strong) IBOutlet NSTextField* googlePassword;

@property (nonatomic, strong) IBOutlet NSTextField* spotifyUsername;
@property (nonatomic, strong) IBOutlet NSTextField* spotifyPassword;

@property (nonatomic, strong) IBOutlet NSTextField* lastFMUsername;
@property (nonatomic, strong) IBOutlet NSTextField* lastFMPassword;

@property (nonatomic, strong) IBOutlet NSTextField* localMusicFolderPath;
@property (nonatomic, strong) IBOutlet NSButton* browseLocalMusicFolderPathButton;

@end

@implementation PreferencesWindowController

-(instancetype)init
{
	self = [super initWithWindowNibName:@"PreferencesWindowController"];
	if (self)
	{
		
	}
	return self;
}

-(void)awakeFromNib
{
	[[self googleUsername] setDelegate:self];
	[[self googlePassword] setDelegate:self];
	[[self spotifyUsername] setDelegate:self];
	[[self spotifyPassword] setDelegate:self];
	[[self localMusicFolderPath] setDelegate:self];
	
	if(![[NSUserDefaults standardUserDefaults] objectForKey:@"lastfmSessionKey"])
	{
		[self loginLastfm:self];
	}
	
	if(![[NSUserDefaults standardUserDefaults] objectForKey:@"googleMusicAuthenticationToken"])
	{
		[self loginGoogleMusic:self];
	}
}

-(void)controlTextDidEndEditing:(NSNotification *)notification
{
	if ([notification object] == [self googleUsername] || [notification object] == [self googlePassword])
	{
		[self loginGoogleMusic:self];
	}
	else if ([notification object] == [self lastFMUsername] || [notification object] == [self lastFMPassword])
	{
		[self loginLastfm:self];
	}
}

-(IBAction)browse:(id)sender
{
	[self setOpenPanel:[NSOpenPanel openPanel]];
	[[self openPanel] setCanChooseFiles:NO];
	[[self openPanel] setCanChooseDirectories:YES];
	[[self openPanel] beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result)
	{
		if (result == NSFileHandlingPanelOKButton)
		{
			[[NSUserDefaults standardUserDefaults] setObject:[[[self openPanel] directoryURL] path] forKey:@"localMusicFolderPath"];
		}
	}];
}

-(void)loginLastfm:(id)sender
{
	NSString* username = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastfmUsername"];
	NSString* password = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastfmPassword"];
	
	if (![username isEqualToString:@""] && ![password isEqualToString:@""])
	{
		[[(AppDelegate*)[NSApp delegate] lastFmController] requestMobileSession];
	}
}

-(void)loginGoogleMusic:(id)sender
{
	NSString* username = [[NSUserDefaults standardUserDefaults] objectForKey:@"googleUsername"];
	NSString* password = [[NSUserDefaults standardUserDefaults] objectForKey:@"googlePassword"];

	if (![username isEqualToString:@""] && ![password isEqualToString:@""])
	{
		[[(AppDelegate*)[NSApp delegate] googleMusicController] loginWithUsername:username password:password];
	}
}

-(IBAction)loginSoundCloud:(id)sender
{
	[[(AppDelegate*)[NSApp delegate] soundCloudController] login];
}

@end
