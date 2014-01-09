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
#import "PlayerToolbarItemViewController.h"
#import "PlayerToolbarItem.h"
#import <AVFoundation/AVAsset.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[NSApp setDelegate:self];
	
	[[self toolbar] setDelegate:self];
	
	[self setPreferencesWindowController:[[PreferencesWindowController alloc] init]];
	
	[[self googleTableController] populateGoogleTable];
	
	[self setQueueArrayController:[[NSArrayController alloc] init]];
	[self setCurrentlyPlayingSongTitle:[[NSString alloc] init]];
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
	[self setPlayerItem:[[self player] currentItem]];
	[[self playerItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
	[[self queueArrayController] removeObjectAtArrangedObjectIndex:0];
	
	[[self googleTableController] setSelectedSong:([[self googleTableController] selectedSong] + 1)];
	[[self googleTableController] addNextQueuedSong];
}

-(IBAction)pause:(id)sender
{
	[[self player] pause];
}

-(IBAction)play:(id)sender
{
//	[[[[self player] currentItem] asset] loadValuesAsynchronouslyForKeys:@[@"metadata"] completionHandler:^{
//		NSError *error = nil;
//		switch ([[[[self player] currentItem] asset] statusOfValueForKey:@"metadata" error:&error])
//		{
//			case AVKeyValueStatusLoaded:
//			{
//				NSArray* metadata = [[[[self player] currentItem] asset] commonMetadata];
//				for (AVMetadataItem* metadataItem in metadata)
//				{
//					if ([[metadataItem commonKey] isEqualToString:@"title"])
//					{
//						[self setCurrentlyPlayingSongTitle:[[metadataItem value] copyWithZone:nil]];
//					}
//				}
//
//				break;
//				// dispatch a block to the main thread that updates the display of asset duration in my user interface,
//				// or do something else interesting with it
//			}
//			default:
//				
//				break;
//				// something went wrong; depending on what it was, we may want to dispatch a
//				// block to the main thread to report the error
//		}
//	}];
	
	[[self player] play];
}

-(void)playerItemDidReachEnd:(id)object
{
	[[self player] advanceToNextItem];
	[self setPlayerItem:[[self player] currentItem]];
	[[self playerItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"status"])
	{
		[[self playerItem] removeObserver:self forKeyPath:keyPath];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:object];
		[self play:self];
	}
}

-(void)startPlayingPlayerItem:(AVPlayerItem*)playerItem withQueueBuildingCompletionHandler:(void(^)(void))completionHandler
{
	[self setPlayer:[AVQueuePlayer queuePlayerWithItems:@[playerItem]]];
	[self setPlayerItem:[[self player] currentItem]];
	[[self playerItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
	
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

-(void)addItem:(NSDictionary*)trackDict toQueue:(AVPlayerItem*)playerItem
{
	[[self queueArrayController] addObject:trackDict];
	[[self player] insertItem:playerItem afterItem:nil];
	NSLog(@"item added to queue. queue size: %ld", [[[self player] items] count]);
}

-(void)clickedToQueueItemAtIndex:(NSInteger)queueIndex
{
	
}

#pragma mark - Table View Controls

-(IBAction)reload:(id)sender
{
	[[self googleTableController] populateGoogleTable];
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
