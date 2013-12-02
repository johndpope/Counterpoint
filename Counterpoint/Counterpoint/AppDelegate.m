//
//  AppDelegate.m
//  Counterpoint
//
//  Created by Becky on 12/2/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
}

-(IBAction)play:(id)sender
{
	;
}

-(IBAction)showPreferences:(id)sender
{
	NSWindowController* windowController = [[NSWindowController alloc] initWithWindow:[self preferencesPanel]];
	[windowController showWindow:self];
}

@end
