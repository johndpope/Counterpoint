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
#import "CurrentTrackToolbarItemViewController.h"
#import "CurrentTrackToolbarItem.h"
#import <AVFoundation/AVAsset.h>
#import "GoogleMusicController.h"
#import "CPTrack.h"
#import "QueuePopoverViewController.h"

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

-(void)setInitializedQueueSubArray:(NSMutableArray *)initalizedQueueSubArray
{
	
}

-(NSMutableArray*)initializedQueueSubArray
{
	//only the first 21 objects in the array will have AVPlayerItems initialized
	//we only want to display these few items in the queue to keep the queue popover controller size down
	//the first object (index 0) is the item currently being played and does not need to be displayed
	
	return [NSMutableArray arrayWithArray:[[[self queueArrayController] arrangedObjects] subarrayWithRange:NSMakeRange(1, 20)]];
}

#pragma mark - Player Controls

-(IBAction)next:(id)sender
{
	[[self player] advanceToNextItem];
	[[[self player] currentItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
	
	//remove the first object in the array, initialize the new track just added to initializedQueueSubArray
	[[self queueArrayController] removeObjectAtArrangedObjectIndex:0];
	[self setCurrentTrack:[[[self queueArrayController] arrangedObjects] objectAtIndex:0]];
	[self getAlbumArtworkForTrack:[self currentTrack]];
	
	CPTrack* trackToInitialize = [[self initializedQueueSubArray] lastObject];
	[self getPlayerItemForTrack:trackToInitialize];
	[[[self queuePopoverViewController] initializedQueueArrayController] setContent:[self initializedQueueSubArray]];
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
	[self next:self];
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

#pragma mark - Table View Controls

-(IBAction)loadAllTables:(id)sender
{
	[[self googleMusicController] loadTracks];
}

-(void)finishedLoadingTracks
{
	[[self tracksArrayController] setContent:[self tracksArray]];
}

-(void)getPlayerItemForTrack:(CPTrack*)track
{
	NSString* songId = [track idString];
	NSString* streamURLString = [[self googleMusicController] getStreamUrl:songId];
	NSURL* streamURL = [[NSURL alloc] initWithString:streamURLString];
	
	AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:streamURL];
	[track setPlayerItem:playerItem];
}

-(void)getAlbumArtworkForTrack:(CPTrack*)track
{
	NSImage* albumArtImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[track albumArtworkImageURLString]]];
	[track setAlbumArtworkImage:albumArtImage];
}

-(void)playSelectedSongAndQueueFollowingTracks
{
	NSInteger selectedRow = [[self table] selectedRow];
	CPTrack* selectedTrack = [[[self tracksArrayController] arrangedObjects] objectAtIndex:selectedRow];
	
	if ([[self currentTrack] isEqual:selectedTrack])
		return;
	
	[self getAlbumArtworkForTrack:selectedTrack];
	
	[self setCurrentTrack:selectedTrack];
		
	[self getPlayerItemForTrack:selectedTrack];
	[self setPlayer:[AVQueuePlayer queuePlayerWithItems:@[[selectedTrack playerItem]]]];
	[[[self player] currentItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
		
	//keeping a copy of the tracksArrayController arrangedObjects at this moment in case the user then filters the tableview after starting to play an item
	//the "queue" popover display will continue to play the tracks in the original order no matter what filtering or arranging the user does after the initial selection
	NSRange range = NSMakeRange(selectedRow, [[[self tracksArrayController] arrangedObjects] count] - selectedRow);
	NSMutableArray* queueArray = [NSMutableArray arrayWithArray:[[[self tracksArrayController] arrangedObjects] subarrayWithRange:range]];
	[[self queueArrayController] setContent:queueArray];
	
	for (CPTrack* track in [self initializedQueueSubArray])
	{
		[self getPlayerItemForTrack:track];
		[[self player] insertItem:[track playerItem] afterItem:nil];
	}
	
	[[[self queuePopoverViewController] initializedQueueArrayController] setContent:[self initializedQueueSubArray]];
}

#pragma mark - Queue Controls

-(IBAction)showQueue:(NSToolbarItem*)queueToolbarItem
{
	[[self queuePopover] showRelativeToRect:[[[self queueToolbarItem] view] bounds] ofView:[[self queueToolbarItem] view] preferredEdge:NSMaxYEdge];
}

-(void)clickedToQueueItemAtIndex:(NSInteger)queueIndex
{
	
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
	
	if ([itemIdentifier isEqualToString:@"currenttrack"])
	{
		CurrentTrackToolbarItem* playerToolbarItem = [[CurrentTrackToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
		return playerToolbarItem;
	}
	
	NSToolbarItem* toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	
	return toolbarItem;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return @[@"currenttrack", @"player", @"queue", @"reload", NSToolbarFlexibleSpaceItemIdentifier];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return @[@"player", NSToolbarFlexibleSpaceItemIdentifier, @"currenttrack", NSToolbarFlexibleSpaceItemIdentifier, @"queue", @"reload"];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return @[ @"currenttrack",@"player",@"queue",@"reload"];
}

@end
