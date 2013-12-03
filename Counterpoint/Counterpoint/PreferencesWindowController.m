//
//  PreferencesViewController.m
//  Counterpoint
//
//  Created by Becky on 12/2/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import "PreferencesWindowController.h"

@interface PreferencesWindowController ()

@property (nonatomic, strong) IBOutlet NSTextField* googleUsername;
@property (nonatomic, strong) IBOutlet NSTextField* googlePassword;

@property (nonatomic, strong) IBOutlet NSTextField* spotifyUsername;
@property (nonatomic, strong) IBOutlet NSTextField* spotifyPassword;

@property (nonatomic, strong) IBOutlet NSTextField* localMusicFolderPath;
@property (nonatomic, strong) IBOutlet NSButton* browseLocalMusicFolderPathButton;

@end

@implementation PreferencesWindowController

-(id)init
{
	self = [super initWithWindowNibName:@"PreferencesWindowController"];
	if (self)
	{
		
	}
	return self;
}

-(IBAction)browse:(id)sender
{
	[self setOpenPanel:[NSOpenPanel openPanel]];
	[[self openPanel] setCanChooseFiles:NO];
	[[self openPanel] setCanChooseDirectories:YES];
	[[self openPanel] beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton)
		{
			[[NSUserDefaults standardUserDefaults] setObject:[[[self openPanel] directoryURL] absoluteString] forKey:@"localMusicFolderPath"];
		}
	}];
}

@end
