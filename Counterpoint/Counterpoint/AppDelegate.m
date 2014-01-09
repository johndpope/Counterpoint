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

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[NSApp setDelegate:self];
	
	[[self toolbar] setDelegate:self];
	
	[self setPreferencesWindowController:[[PreferencesWindowController alloc] init]];
	
	[self setGoogleTableController:[[GoogleTableController alloc] init]];
	[[[self tabView] tabViewItemAtIndex:1] setView:[[self googleTableController] view]];
	[[self googleTableController] populateGoogleTable];
	
	[self setQueueArrayController:[[NSArrayController alloc] init]];
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
	
	NSTabViewItem* selectedTabView = [[self tabView] selectedTabViewItem];
	if ([[selectedTabView label] isEqualToString:@"Google Music"])
	{
		[[self googleTableController] setSelectedSong:([[self googleTableController] selectedSong] + 1)];
		[[self googleTableController] addNextQueuedSong];
	}
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
	[self setPlayerItem:[[self player] currentItem]];
	[[self playerItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"status"])
	{
		[[self playerItem] removeObserver:self forKeyPath:keyPath];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:object];
		[[self player] play];
	}
}

-(void)startPlayingPlayerItem:(AVPlayerItem*)playerItem withQueueBuildingCompletionHandler:(void(^)(void))completionHandler
{
	[self setPlayer:[AVQueuePlayer queuePlayerWithItems:@[playerItem]]];
	[self setPlayerItem:[[self player] currentItem]];
	[[self playerItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
	[[self toolbar] setSelectedItemIdentifier:@"play"];
	
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

#pragma mark - Table View Controls

-(IBAction)reload:(id)sender
{
	NSTabViewItem* selectedTabView = [[self tabView] selectedTabViewItem];
	if ([[selectedTabView label] isEqualToString:@"Google Music"])
	{
		[[self googleTableController] populateGoogleTable];
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
	NSToolbarItem* toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	
	if ([itemIdentifier isEqualToString:@"player"])
	{
		PlayerToolbarItemViewController* playerVC = [[PlayerToolbarItemViewController alloc] init];
		NSView* playerView = [playerVC view];
		[toolbarItem setMinSize:[playerView bounds].size];
		[toolbarItem setMaxSize:[playerView bounds].size];
		[toolbarItem setView:playerView];
		
		[toolbarItem setEnabled:YES];
	}
	
	return toolbarItem;
}

@end
