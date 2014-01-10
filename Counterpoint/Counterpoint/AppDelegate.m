//
//  AppDelegate.m
//  Counterpoint
//
//  Created by Becky on 12/2/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import "AppDelegate.h"
#import "PreferencesWindowController.h"
#import "PlayerToolbarItemViewController.h"
#import "PlayerToolbarItem.h"
#import <AVFoundation/AVAsset.h>
#import "GoogleMusicController.h"
#import "CPTrack.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[NSApp setDelegate:self];
	[[self toolbar] setDelegate:self];
	
	[self setPreferencesWindowController:[[PreferencesWindowController alloc] init]];
	
	[self setQueueArrayController:[[NSArrayController alloc] init]];
	[self setTracksArray:[[NSMutableArray alloc] init]];
	[self setCurrentTrack:[[CPTrack alloc] init]];
	
	[self setGoogleMusicController:[[GoogleMusicController alloc] init]];
	[self loadAllTables:self];
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
	[[self window] setIsVisible:YES];
	return YES;
}

#pragma mark - Player Controls

-(IBAction)next:(id)sender
{
	[[self player] advanceToNextItem];
	[[[self player] currentItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
	
	[self setCurrentTrack:[[[self queueArrayController] arrangedObjects] objectAtIndex:0]];
	[[self queueArrayController] removeObjectAtArrangedObjectIndex:0];
	
	[self addNextQueuedSong];
}

-(IBAction)pause:(id)sender
{
	[[self player] pause];
}

-(IBAction)play:(id)sender
{	
	[[self player] play];
}

-(void)playerItemDidReachEnd:(id)object
{
	[[self player] advanceToNextItem];
	[[[self player] currentItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"status"])
	{
		[[[self player] currentItem] removeObserver:self forKeyPath:keyPath];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:object];
		[self play:self];
	}
}

-(void)startPlayingPlayerItem:(AVPlayerItem*)playerItem withQueueBuildingCompletionHandler:(void(^)(void))completionHandler
{
	[self setPlayer:[AVQueuePlayer queuePlayerWithItems:@[playerItem]]];
	[[[self player] currentItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
	
	for (NSInteger i = 0; i < [[[self queueArrayController] arrangedObjects] count]; i++)
	{
		[[self queueArrayController] removeObjectAtArrangedObjectIndex:i];
	}
	
	if (completionHandler)
		completionHandler();
}


#pragma mark - Queue Controls

-(IBAction)showQueue:(NSToolbarItem*)queueToolbarItem
{
	[[self queuePopover] showRelativeToRect:[[[self queueToolbarItem] view] bounds] ofView:[[self queueToolbarItem] view] preferredEdge:NSMaxYEdge];
}

-(void)addItem:(CPTrack*)track toQueue:(AVPlayerItem*)playerItem
{
	[[self queueArrayController] addObject:track];
	[[self player] insertItem:playerItem afterItem:nil];
	NSLog(@"item added to queue. queue size: %ld", [[[self player] items] count]);
}

-(void)clickedToQueueItemAtIndex:(NSInteger)queueIndex
{
	
}

-(void)addNextQueuedSong
{
//	NSInteger indexOfNextSongToQueue = [self selectedSong] + 20;
//	AVPlayerItem* playerItem = [self getPlayerItemForSong:indexOfNextSongToQueue];
//	[[NSApp delegate] addItem:[[self tracksArrayController] arrangedObjects][indexOfNextSongToQueue] toQueue:playerItem];
}

#pragma mark - Table View Controls

-(IBAction)loadAllTables:(id)sender
{
	[[self googleMusicController] loadTracks];
}

-(void)finishedLoadingTracks
{
	[[self tracksArrayController] setContent:[self tracksArray]];
}

-(AVPlayerItem*)getPlayerItemForSong:(NSInteger)songRow
{
	CPTrack* track = [[[self tracksArrayController] arrangedObjects] objectAtIndex:songRow];
	NSString* songId = [track idString];
	NSString* streamURLString = [[self googleMusicController] getStreamUrl:songId];
	NSURL* streamURL = [[NSURL alloc] initWithString:streamURLString];
	
	return [AVPlayerItem playerItemWithURL:streamURL];
}

-(void)playSelectedSongAndQueueFollowingTracks
{
	NSInteger selectedRow = [[self table] selectedRow];
	CPTrack* selectedTrack = [[[self tracksArrayController] arrangedObjects] objectAtIndex:selectedRow];
	
	if ([[self currentTrack] isEqual:selectedTrack])
		return;
	
	AVPlayerItem* playerItem = [self getPlayerItemForSong:selectedRow];
	[self setCurrentTrack:selectedTrack];
	
	[self startPlayingPlayerItem:playerItem withQueueBuildingCompletionHandler:^{
		for (NSInteger i = selectedRow+1; i < [[[self tracksArrayController] arrangedObjects] count] && i < selectedRow + 20; i++)
		{
			[[NSApp delegate] addItem:[[self tracksArrayController] arrangedObjects][i] toQueue:[self getPlayerItemForSong:i]];
		}
	}];
}

#pragma mark - Preferences

-(IBAction)showPreferences:(id)sender
{
	[[self preferencesWindowController] showWindow:self];
}

#pragma mark - Toolbar

-(NSToolbarItem*)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
	if ([itemIdentifier isEqualToString:@"player"])
	{
		PlayerToolbarItem* playerToolbarItem = [[PlayerToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
		return playerToolbarItem;
	}
	
	NSToolbarItem* toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	
	return toolbarItem;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return @[@"player",@"queue",@"reload",NSToolbarFlexibleSpaceItemIdentifier];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return @[@"player", NSToolbarFlexibleSpaceItemIdentifier, @"queue", @"reload"];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return @[@"player",@"queue",@"reload"];
}

@end
