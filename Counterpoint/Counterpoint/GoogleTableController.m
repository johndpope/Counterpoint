//
//  GoogleViewController.m
//  Counterpoint
//
//  Created by Rebecca Henderson on 12/12/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import "GoogleTableController.h"
#import "GoogleMusicController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface GoogleTableController ()

@end

@implementation GoogleTableController

-(id)init
{
	self = [super init];
	if (self)
	{
		_googleMusicController = [[GoogleMusicController alloc] init];
	}
	return self;
}

-(void)populateGoogleTable
{
	if (![self googleMusicController])
		[self setGoogleMusicController:[[GoogleMusicController alloc] init]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadGoogleTracks) name:@"GoogleMusicTracksLoaded" object:nil];
	
	[[self googleMusicController] loginWithUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"googleUsername"] password:[[NSUserDefaults standardUserDefaults] objectForKey:@"googlePassword"]];
}

-(void)loadGoogleTracks
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[self songsLabel] setStringValue:[NSString stringWithFormat:@"%ld Songs Available", [[[self googleMusicController] songArray] count]]];
	[[self googleArrayController] setContent:[[self googleMusicController] songArray]];
}

-(AVPlayerItem*)getPlayerItemForSelectedSong
{
	NSInteger selectedRow = [[self googleTable] selectedRow];
	NSDictionary* songDictionary = [[[self googleArrayController] arrangedObjects] objectAtIndex:selectedRow];
	NSString* songId = [songDictionary objectForKey:@"id"];
	NSString* streamURLString = [[self googleMusicController] getStreamUrl:songId];
	NSURL* streamURL = [[NSURL alloc] initWithString:streamURLString];
	
	return [AVPlayerItem playerItemWithURL:streamURL];
}

-(void)doubleClickTableRow
{
	AVPlayerItem* playerItem = [self getPlayerItemForSelectedSong];
	
	[(AppDelegate*)[NSApp delegate] playWithPlayerItem:playerItem];
}

@end
