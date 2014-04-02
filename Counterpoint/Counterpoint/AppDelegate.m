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
#import "CPPlaylist.h"
#import "QueuePopoverViewController.h"
#import	"LastFMController.h"

@implementation AppDelegate

#pragma mark - Application

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[NSApp setDelegate:self];
	[[self toolbar] setDelegate:self];
	
	//set up preferences
	[self setPreferencesWindowController:[[PreferencesWindowController alloc] init]];
	
	//set up table view
	NSMenu* menu = [[NSMenu alloc] init];
	[menu addItemWithTitle:@"Add to Queue" action:@selector(queueSong:) keyEquivalent:@""];
	[menu addItemWithTitle:@"Play Next" action:@selector(queueSong:) keyEquivalent:@""];
	[[self table] setMenu:menu];
	
	//set up music service controllers
	[self setLastFmController:[[LastFMController alloc] init]];
	[self setGoogleMusicController:[[GoogleMusicController alloc] init]];
	[self loadAllTables:self];
	
	[self setSidebarItemsArray:[NSMutableArray arrayWithObjects:@{@"title" : @"SOURCES",
																  @"children" :
																	  @[@{@"title" : @"All Tracks"},
																		@{@"title" : @"Google Music"},
																		@{@"title": @"SoundCloud"}],
																  @"header" : @(YES)}, nil]];
	
	//set up AVPlayer
	[self setPlayer:[[AVQueuePlayer alloc] init]];
	[[self player] setActionAtItemEnd:AVPlayerActionAtItemEndAdvance];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];	
	[[self player] addObserver:self forKeyPath:@"status" options:0 context:nil];
	[[self player] addObserver:self forKeyPath:@"currentItem" options:0 context:nil];
	[[self player] addObserver:self forKeyPath:@"rate" options:0 context:nil];
	
	//set up current track and queue
	[self setQueueArrayController:[[NSArrayController alloc] init]];
	[self setTracksArray:[[NSMutableArray alloc] init]];
	[self setPlaylistsArray:[[NSMutableArray alloc] init]];
	[self setCurrentTrack:[[CPTrack alloc] init]];
	[[self queueArrayController] addObserver:self forKeyPath:@"content" options:0 context:nil];
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
	[[self window] setIsVisible:YES];
	return YES;
}

-(void)dealloc
{
	[_player removeTimeObserver:_playerTimeObserverReturnValue];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_queueArrayController removeObserver:self forKeyPath:@"content"];
}

#pragma mark - Player Controls

-(void)advanceToNextTrack
{
	CPTrack* track = [self getTracksArrayControllerTrackForQueueArrayControllerTrack:[[[self queueArrayController] content] objectAtIndex:0]];
	[track setCurrentlyPlaying:NO];
	
	//remove the first object in the array, initialize the new track
	[[self queueArrayController] removeObject:[self currentTrack]];
	[self setQueueArrayControllerSelectedIndexes];
	
	if ([[[self queueArrayController] content] count] > 0)
	{
		[self setCurrentTrack:[[[self queueArrayController] content] objectAtIndex:0]];
		[self getAlbumArtworkForTrack:[self currentTrack]];
		
		if ([[[self queueArrayController] selectedObjects] count] > 0)
			[self queueSong:[[[self queueArrayController] selectedObjects] objectAtIndex:0] addToFrontOfQueue:YES addToSelectedObjects:NO];
	}	
}

-(void)next:(id)sender
{
	[[[self player] currentItem] seekToTime:kCMTimeZero];
	[[self player] advanceToNextItem];
	
	[self advanceToNextTrack];
}

-(void)playerItemDidReachEnd:(NSNotification*)notification
{
	dispatch_async(dispatch_get_main_queue(), ^{
				
		[[notification object] seekToTime:kCMTimeZero];
		
		[[self lastFmController] scrobbleCPTrack:[self currentTrack]];
		
		[self advanceToNextTrack];
	});
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

-(void)finishedLoadingPlaylists
{
	NSMutableArray* playlistsToAdd = [NSMutableArray array];
	for (CPPlaylist* playlist in [self playlistsArray])
	{
		[playlistsToAdd addObject:@{@"title": [playlist name]}];
	}
	
	[self setSidebarItemsArray:[NSMutableArray arrayWithArray:@[[self sidebarItemsArray][0], @{@"title": @"PLAYLISTS", @"children" : playlistsToAdd, @"header" : @(YES)}]]];
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
	if ([[self currentTrack] isEqual:track])
		return;
	
	[[self currentTrack] setCurrentlyPlaying:NO];
	[[self player] removeAllItems];
	
	[self getAlbumArtworkForTrack:track];
	[self setCurrentTrack:track];
	[self getPlayerItemForTrack:track];
	[[self player] insertItem:[track playerItem] afterItem:nil];
	
	[[[self player] currentItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
	
	//keeping a copy of the tracksArrayController arrangedObjects at this moment in case the user then filters the tableview after starting to play an item
	//the "queue" popover display will continue to play the tracks in the original order no matter what filtering or arranging the user does after the initial selection
	NSInteger selectedRow = [[[self tracksArrayController] arrangedObjects] indexOfObject:track];
	NSRange range = NSMakeRange(selectedRow, [[[self tracksArrayController] arrangedObjects] count] - selectedRow);
	NSMutableArray* queueArray = [NSMutableArray arrayWithArray:[[[self tracksArrayController] arrangedObjects] subarrayWithRange:range]];
	[[self queueArrayController] setContent:queueArray];
	
	if ([[[self queueArrayController] selectedObjects] count] > 0)
		[self queueSong:[[[self queueArrayController] selectedObjects] objectAtIndex:0] addToFrontOfQueue:YES addToSelectedObjects:NO];
}

-(void)playSongFromTable:(id)sender
{
	CPTrack* selectedTrack = [sender objectAtIndex:0];
	
	[self playSong:selectedTrack];
}

-(void)queueSong:(CPTrack*)track addToFrontOfQueue:(BOOL)addToFrontOfQueue addToSelectedObjects:(BOOL)addToSelectedObjects
{
	[self getPlayerItemForTrack:track];
	
	if (addToFrontOfQueue)
	{
		if (addToSelectedObjects)
			[[self queueArrayController] insertObject:track atArrangedObjectIndex:1];
		if (![[[self player] items] containsObject:[track playerItem]])
			[[self player] insertItem:[track playerItem] afterItem:[[self player] currentItem]];
	}
	else
	{
		if (addToSelectedObjects)
		{
			if ([[[self queueArrayController] selectedObjects] count] == 0)
				[self playSong:track];
			else
				[[self queueArrayController] insertObject:track atArrangedObjectIndex:[[[self queueArrayController] selectedObjects] count]+1];
		}
	}
	
	[self setQueueArrayControllerSelectedIndexes];
}

-(void)queueSong:(id)sender
{
	NSInteger selectedSongIndex = [[self table] selectedRow];
	CPTrack* selectedTrack = [[[self tracksArrayController] arrangedObjects] objectAtIndex:selectedSongIndex];
	
	if ([[(NSMenuItem*)sender title] isEqualToString:@"Play Next"])
		[self queueSong:selectedTrack addToFrontOfQueue:YES addToSelectedObjects:YES];
	else
		[self queueSong:selectedTrack addToFrontOfQueue:NO addToSelectedObjects:YES];
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
		NSMutableArray* tracks = [NSMutableArray arrayWithArray:[[self tracksArrayController] content]];
		NSUInteger count = [tracks count];
		//start at second track to leave the currently playing track alone
		for (NSUInteger i = 0; i < count; ++i)
		{
			// Select a random element between i and end of array to swap with.
			NSInteger nElements = count - i;
			NSInteger n = arc4random_uniform((int)nElements) + i;
			[tracks exchangeObjectAtIndex:i withObjectAtIndex:n];
		}
		
		[tracks exchangeObjectAtIndex:0 withObjectAtIndex:[tracks indexOfObject:[self currentTrack]]];
		
		newQueue = tracks;
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
	if ([items count] > 1)
		[[self player] removeItem:[items lastObject]];
	 
	[self queueSong:[[[self queueArrayController] selectedObjects] objectAtIndex:0] addToFrontOfQueue:YES addToSelectedObjects:NO];
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
				NSLog(@"Current player item state = unknown");
		}
		else if (object == [self player])
		{
			if ([[self player] status] == AVPlayerStatusFailed)
			{
				NSLog(@"Player state = failed");
			}
			else if ([[self player] status] == AVPlayerStatusUnknown)
			{
				NSLog(@"Player state = unknown");
			}
		}
	}
	else if ([keyPath isEqualToString:@"content"])
	{
		[self setQueueArrayControllerSelectedIndexes];
	}
	else if ([keyPath isEqualToString:@"currentItem"])
	{
		[[[self currentTrackToolbarItem] viewController] setupTrackDurationSlider];
	}
	else if ([keyPath isEqualToString:@"rate"])
	{
		NSLog(@"Rate changed to: %f", (float)[(AVPlayer*)object rate]);
	}
}

#pragma mark - Outline View Delegate

-(NSView*)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)treeNode
{
	NSDictionary *item = [treeNode representedObject];
    BOOL isHeader = [[item objectForKey:@"header"] boolValue];
    return [outlineView makeViewWithIdentifier: isHeader ? @"HeaderCell" : @"DataCell"
										 owner:self];
}

-(void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	NSArray* selectedNodes = [[self sidebarController] selectedNodes];
	if ([selectedNodes count] == 1)
	{
		NSTreeNode* selectedNode = selectedNodes[0];
		if ([selectedNode isLeaf])
		{
			NSString* parentNodeTitle = [[selectedNode parentNode] representedObject][@"title"];
			if ([parentNodeTitle isEqualToString:@"PLAYLISTS"])
			{
				NSString* playlistName = [selectedNode representedObject][@"title"];
				NSArray* playlistsOfTitle = [[self playlistsArray] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@", playlistName]];
				for (CPPlaylist* playlist in playlistsOfTitle)
				{
					NSArray* idsOfTracksInPlaylist = [[playlist tracks] valueForKey:@"trackId"];
					NSPredicate* playlistFilter = [NSPredicate predicateWithFormat:@"idString IN %@", idsOfTracksInPlaylist];
					[[self tracksArrayController] setFilterPredicate:playlistFilter];
				}
			}
			else
			{
				NSString* sourceName = [selectedNode representedObject][@"title"];
				if ([sourceName isEqualToString:@"All Tracks"])
				{
					[[self tracksArrayController] setFilterPredicate:nil];
				}
			}
		}
	}
}

@end
