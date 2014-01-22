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
	
	NSRange range = NSMakeRange(1, 20);
	if ([[[self queueArrayController] arrangedObjects] count] < 20)
		range = NSMakeRange(1, [[[self queueArrayController] arrangedObjects] count]-1);
	
	return [NSMutableArray arrayWithArray:[[[self queueArrayController] arrangedObjects] subarrayWithRange:range]];
}

//sets the track to the object from tracksArrayController with currently playing flag set to 1
-(void)setCurrentTrack:(CPTrack *)currentTrack
{
	CPTrack* track = [self getTracksArrayControllerTrackForQueueArrayControllerTrack:currentTrack];
	[track setCurrentlyPlaying:YES];
	_currentTrack = track;
}

-(CPTrack*)getTracksArrayControllerTrackForQueueArrayControllerTrack:(CPTrack*)queueArrayControllerTrack
{
	NSUInteger index = [[[self tracksArrayController] content] indexOfObject:queueArrayControllerTrack];
	if (index != NSNotFound)
		return [[[self tracksArrayController] content] objectAtIndex:index];
	else
		return nil;
}

#pragma mark - Player Controls

-(IBAction)next:(id)sender
{
	[[self player] removeTimeObserver:[self playerTimeObserverReturnValue]];
	
	[[self player] advanceToNextItem];
	
	//if the song we're skipping too hasn't quite buffered yet, add the observer to play, otherwise just update the duration stuff now
	if ([[[self player] currentItem] status] == AVPlayerItemStatusReadyToPlay)
		[self setupTrackDurationSlider];
	else
		[[[self player] currentItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
	
	CPTrack* track = [self getTracksArrayControllerTrackForQueueArrayControllerTrack:[[[self queueArrayController] arrangedObjects] objectAtIndex:0]];
	[track setCurrentlyPlaying:NO];
	
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
	[[self player] removeTimeObserver:[self playerTimeObserverReturnValue]];
	
	//if the song we're skipping too hasn't quite buffered yet, add the observer to play, otherwise just update the duration stuff now
	if ([[[self player] currentItem] status] == AVPlayerItemStatusReadyToPlay)
	[self setupTrackDurationSlider];
	else
	[[[self player] currentItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
	
	CPTrack* track = [self getTracksArrayControllerTrackForQueueArrayControllerTrack:[[[self queueArrayController] arrangedObjects] objectAtIndex:0]];
	[track setCurrentlyPlaying:NO];
	
	//remove the first object in the array, initialize the new track just added to initializedQueueSubArray
	[[self queueArrayController] removeObjectAtArrangedObjectIndex:0];
	[self setCurrentTrack:[[[self queueArrayController] arrangedObjects] objectAtIndex:0]];
	[self getAlbumArtworkForTrack:[self currentTrack]];
	
	CPTrack* trackToInitialize = [[self initializedQueueSubArray] lastObject];
	[self getPlayerItemForTrack:trackToInitialize];
	[[[self queuePopoverViewController] initializedQueueArrayController] setContent:[self initializedQueueSubArray]];
}

-(void)setupTrackDurationSlider
{
	[[[self currentTrackToolbarItem] viewController] updateDuration];
	[[[[self currentTrackToolbarItem] viewController] durationSlider] setMinValue:0.0];
	[[[[[self currentTrackToolbarItem] viewController] durationSlider] animator] setFloatValue:0.0];
	
	//this return value needs to be retained so it can be used when sending player the removeTimeObserver: message
	[self setPlayerTimeObserverReturnValue:[[self player] addPeriodicTimeObserverForInterval:CMTimeMake(1, 1000) queue:dispatch_get_current_queue() usingBlock:^(CMTime time)
											{
												[[[self currentTrackToolbarItem] viewController] updateCurrentTime];
											}]];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"status"]) //we'll only hit this when playing the first item in the queue or if we skip to the next track before the player has buffered the song completely
	{
		if (object == [[self player] currentItem])
		{
			if ([[[self player] currentItem] status] == AVPlayerStatusReadyToPlay)
			{
				[[[self player] currentItem] removeObserver:self forKeyPath:keyPath];
				[self setupTrackDurationSlider];
				[self play:self];
			}
			else if ([[[self player] currentItem] status] == AVPlayerItemStatusFailed)
			{
				NSAlert* alert = [NSAlert alertWithMessageText:@"Error buffering stream" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
				NSInteger result = [alert runModal];
				if (result == NSAlertDefaultReturn)
					[self next:self];
			}
			else if ([[[self player] currentItem] status] == AVPlayerStatusUnknown)
				NSLog(@"What does this mean?");
		}
		else if (object == [self player])
		{
			if ([[self player] status] == AVPlayerStatusFailed)
			{
				NSLog(@"Is this happening either?");
			}
			else if ([[self player] status] == AVPlayerStatusUnknown)
			{
				NSLog(@"Is this happening?");
			}
		}
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
	
	if ([self player])
	{
		if ([[self currentTrack] isEqual:selectedTrack])
			return;
		
		[[self currentTrack] setCurrentlyPlaying:NO];
		[[self player] removeAllItems];
	}
	else
		[self setPlayer:[[AVQueuePlayer alloc] init]];
		
	[self getAlbumArtworkForTrack:selectedTrack];
	[self setCurrentTrack:selectedTrack];
	[self getPlayerItemForTrack:selectedTrack];
	[[self player] insertItem:[selectedTrack playerItem] afterItem:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
	[[[self player] currentItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
	[[self player] addObserver:self forKeyPath:@"status" options:0 context:nil];
		
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
		[self setPlayerToolbarItem:playerToolbarItem];
		return [self playerToolbarItem];
	}
	
	if ([itemIdentifier isEqualToString:@"currenttrack"])
	{
		CurrentTrackToolbarItem* currentTrackToolbarItem = [[CurrentTrackToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
		[self setCurrentTrackToolbarItem:currentTrackToolbarItem];
		
		return [self currentTrackToolbarItem];
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
