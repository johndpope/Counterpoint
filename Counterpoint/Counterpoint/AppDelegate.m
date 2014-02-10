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

#pragma mark - Application

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[NSApp setDelegate:self];
	[[self toolbar] setDelegate:self];
	
	[self setPreferencesWindowController:[[PreferencesWindowController alloc] init]];
	
	[self setQueueArrayController:[[NSArrayController alloc] init]];
	[self setTracksArray:[[NSMutableArray alloc] init]];
	[self setCurrentTrack:[[CPTrack alloc] init]];
	
	NSMenu* menu = [[NSMenu alloc] init];
	[menu addItemWithTitle:@"Add to Queue" action:@selector(queueSong:) keyEquivalent:@""];
	[menu addItemWithTitle:@"Play Next" action:@selector(queueSong:) keyEquivalent:@""];
	[[self table] setMenu:menu];
	
	[self setGoogleMusicController:[[GoogleMusicController alloc] init]];
	[self loadAllTables:self];
	
	[[self queueArrayController] addObserver:self forKeyPath:@"content" options:0 context:nil];
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
	[[self window] setIsVisible:YES];
	return YES;
}

-(void)dealloc
{
	[[self queueArrayController] removeObserver:self forKeyPath:@"content"];
}

#pragma mark - Player Controls

-(void)advanceToNextTrack
{
	//if the song we're skipping too hasn't quite buffered yet, add the observer to play, otherwise just update the duration stuff now
	if ([[[self player] currentItem] status] == AVPlayerItemStatusReadyToPlay)
		[[[self currentTrackToolbarItem] viewController] setupTrackDurationSlider];
	else
		[[[self player] currentItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
	
	CPTrack* track = [self getTracksArrayControllerTrackForQueueArrayControllerTrack:[[[self queueArrayController] content] objectAtIndex:0]];
	[track setCurrentlyPlaying:NO];
	
	//remove the first object in the array, initialize the new track
	[[self queueArrayController] removeObject:[self currentTrack]];
	[self setQueueArrayControllerSelectedIndexes];
	[self setCurrentTrack:[[[self queueArrayController] content] objectAtIndex:0]];
	[self getAlbumArtworkForTrack:[self currentTrack]];
	
	CPTrack* trackToInitialize = [[[self queueArrayController] selectedObjects] lastObject];
	[self getPlayerItemForTrack:trackToInitialize];
}

-(void)next:(id)sender
{
	[[self player] removeTimeObserver:[self playerTimeObserverReturnValue]];
	
	[[self player] advanceToNextItem];
	
	[self advanceToNextTrack];
}

-(void)playerItemDidReachEnd:(id)object
{
	[[self player] removeTimeObserver:[self playerTimeObserverReturnValue]];
	
	[self advanceToNextTrack];
}

-(void)pause:(id)sender
{
	[[self player] pause];
}

-(void)play:(id)sender
{	
	[[self player] play];
}

#pragma mark - Table View Controls

-(IBAction)loadAllTables:(id)sender
{
	[[self googleMusicController] loadTracks];
}

-(void)finishedLoadingTracks
{
	NSSortDescriptor* trackSort = [[NSSortDescriptor alloc] initWithKey:@"trackNumber" ascending:YES];
	NSSortDescriptor* albumSort = [[NSSortDescriptor alloc] initWithKey:@"album" ascending:YES];
	NSSortDescriptor* artistSort = [[NSSortDescriptor alloc] initWithKey:@"artist" ascending:YES];
	
	[[self tracksArray] sortUsingDescriptors:@[artistSort, albumSort, trackSort]];
	
	[[self tracksArrayController] setContent:[self tracksArray]];
}

-(void)getPlayerItemForTrack:(CPTrack*)track
{
	if (![track playerItem])
	{
		NSString* songId = [track idString];
		NSString* streamURLString = [[self googleMusicController] getStreamUrl:songId];
		NSURL* streamURL = [[NSURL alloc] initWithString:streamURLString];
		
		AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:streamURL];
		[track setPlayerItem:playerItem];
	}
}

-(void)getAlbumArtworkForTrack:(CPTrack*)track
{
	NSImage* albumArtImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[track albumArtworkImageURLString]]];
	[track setAlbumArtworkImage:albumArtImage];
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

-(void)playSong:(CPTrack*)track
{
	if ([self player])
	{
		if ([[self currentTrack] isEqual:track])
			return;
		
		[[self currentTrack] setCurrentlyPlaying:NO];
		[[self player] removeAllItems];
	}
	else
		[self setPlayer:[[AVQueuePlayer alloc] init]];
	
	[self getAlbumArtworkForTrack:track];
	[self setCurrentTrack:track];
	[self getPlayerItemForTrack:track];
	[[self player] insertItem:[track playerItem] afterItem:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
	[[[self player] currentItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
	[[self player] addObserver:self forKeyPath:@"status" options:0 context:nil];
	
	//keeping a copy of the tracksArrayController arrangedObjects at this moment in case the user then filters the tableview after starting to play an item
	//the "queue" popover display will continue to play the tracks in the original order no matter what filtering or arranging the user does after the initial selection
	NSInteger selectedRow = [[[self tracksArrayController] arrangedObjects] indexOfObject:track];
	NSRange range = NSMakeRange(selectedRow, [[[self tracksArrayController] arrangedObjects] count] - selectedRow);
	NSMutableArray* queueArray = [NSMutableArray arrayWithArray:[[[self tracksArrayController] arrangedObjects] subarrayWithRange:range]];
	[[self queueArrayController] setContent:queueArray];
	
	for (CPTrack* track in [[self queueArrayController] selectedObjects])
	{
		[self getPlayerItemForTrack:track];
		[[self player] insertItem:[track playerItem] afterItem:nil];
	}
}

-(void)playSongFromTable:(id)sender
{
	CPTrack* selectedTrack = [sender objectAtIndex:0];
	
	[self playSong:selectedTrack];
}

-(void)queueSong:(CPTrack*)track addToFrontOfQueue:(BOOL)addToFrontOfQueue
{
	[self getPlayerItemForTrack:track];
	
	if (addToFrontOfQueue)
	{
		[[self queueArrayController] insertObject:track atArrangedObjectIndex:1];
		[[self player] insertItem:[track playerItem] afterItem:[[self player] currentItem]];
	}
	else
	{
		[[self queueArrayController] insertObject:track atArrangedObjectIndex:20];
		[[self player] insertItem:[track playerItem] afterItem:nil];
	}
	
	[self setQueueArrayControllerSelectedIndexes];
}

-(void)queueSong:(id)sender
{
	NSInteger selectedSongIndex = [[self table] selectedRow];
	CPTrack* selectedTrack = [[[self tracksArrayController] arrangedObjects] objectAtIndex:selectedSongIndex];
	
	if ([[(NSMenuItem*)sender title] isEqualToString:@"Play Next"])
		[self queueSong:selectedTrack addToFrontOfQueue:YES];
	else
		[self queueSong:selectedTrack addToFrontOfQueue:NO];
}

#pragma mark - Queue Controls

//set selectedIndexes of the queueArrayController
//the selectedObjects will be used to populate the queue popover
-(void)setQueueArrayControllerSelectedIndexes
{
	NSIndexSet* indexSet = nil;
	if ([[[self queueArrayController] content] count] > 21)
		indexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(1, 20)];
	else if ([[[self queueArrayController] content] count] > 0)
		indexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(1, [[[self queueArrayController] arrangedObjects] count] -1)];
	else
		indexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0,0)];
	[[self queueArrayController] setSelectionIndexes:indexSet];
}

-(void)clickedToQueueItemAtIndex:(NSInteger)queueIndex
{
	CPTrack* selectedTrack = [[[self queueArrayController] selectedObjects] objectAtIndex:queueIndex];
	[self playSong:selectedTrack];
}

-(void)shuffle:(id)sender
{
	NSArray* newQueue = [NSArray array];
	if ([sender state] == NSOnState)
	{
		NSMutableArray* queuedItems = [NSMutableArray arrayWithArray:[[self queueArrayController] content]];
		NSUInteger count = [queuedItems count];
		//start at second track to leave the currently playing track alone
		for (NSUInteger i = 1; i < count; ++i)
		{
			// Select a random element between i and end of array to swap with.
			NSInteger nElements = count - i;
			NSInteger n = arc4random_uniform((int)nElements) + i;
			[queuedItems exchangeObjectAtIndex:i withObjectAtIndex:n];
		}
		newQueue = queuedItems;
	}
	else
	{
		NSUInteger index = [[[self tracksArrayController] arrangedObjects] indexOfObject:[self currentTrack]];
		NSRange range = NSMakeRange(index, [[[self tracksArrayController] arrangedObjects] count] - index);
		NSMutableArray* queueArray = [NSMutableArray arrayWithArray:[[[self tracksArrayController] arrangedObjects] subarrayWithRange:range]];
		newQueue = queueArray;
	}
	
	[[self queueArrayController] setContent:newQueue];
	
	NSArray* items = [[self player] items];
    for (AVPlayerItem* item in [items copy]) {
        if (item == [[self player] currentItem]) {
            continue; // don't remove the currently played item
        }
        [[self player] removeItem:item];
    }
	 
	for (CPTrack* track in [[self queueArrayController] selectedObjects])
	{
		[self getPlayerItemForTrack:track];
		[[self player] insertItem:[track playerItem] afterItem:nil];
	}
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
	return @[@"currenttrack", @"player", NSToolbarFlexibleSpaceItemIdentifier];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return @[@"player", NSToolbarFlexibleSpaceItemIdentifier, @"currenttrack", NSToolbarFlexibleSpaceItemIdentifier];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return @[ @"currenttrack",@"player"];
}

#pragma mark - Key Value Observing

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"status"]) //we'll only hit this when playing the first item in the queue or if we skip to the next track before the player has buffered the song completely
	{
		if (object == [[self player] currentItem])
		{
			if ([[[self player] currentItem] status] == AVPlayerStatusReadyToPlay)
			{
				[[[self player] currentItem] removeObserver:self forKeyPath:keyPath];
				[[[self currentTrackToolbarItem] viewController] setupTrackDurationSlider];
				[self play:self];
			}
			else if ([[[self player] currentItem] status] == AVPlayerItemStatusFailed)
			{
				NSAlert* alert = [NSAlert alertWithMessageText:@"Error buffering stream" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
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
	else if ([keyPath isEqualToString:@"content"])
	{
		[self setQueueArrayControllerSelectedIndexes];
	}
}

@end
