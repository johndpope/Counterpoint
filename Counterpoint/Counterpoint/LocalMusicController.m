//
//  LocalMusicController.m
//  Counterpoint
//
//  Created by Becky on 4/23/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import "LocalMusicController.h"
#import "CPTrack.h"
#import "AppDelegate.h"

@implementation LocalMusicController

-(NSArray*)findTracksInDirectoryPath:(NSString*)directoryPath
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSURL* fileURL = [NSURL URLWithString:directoryPath];
	if (!fileURL)
	{
		NSLog(@"File URL could not be created with path: %@", directoryPath);
		return nil;
	}
	
	NSDirectoryEnumerator* dirEnum = [fileManager enumeratorAtURL:fileURL includingPropertiesForKeys:nil options:0 errorHandler:^BOOL(NSURL *url, NSError *error) {
		NSLog(@"Error creating directory enumertator for URL: %@\n Error: %@", url, error);
		return NO;
	}];
	
	NSMutableArray* tracks = [NSMutableArray array];
	
	NSURL* file;
	while ((file = [dirEnum nextObject]))
	{
		NSString* filePath = [file path];
		BOOL isDirectory = NO;
		BOOL fileExists = [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
		if (fileExists && isDirectory)
			[tracks addObjectsFromArray:[self findTracksInDirectoryPath:[file absoluteString]]];
		else if (fileExists)
		{
			CPTrack* track = [[CPTrack alloc] init];
			[track setStreamURLString:filePath];
			[track setServiceType:CPServiceTypeLocalMusic];
			[tracks addObject:track];
		}
	}
	
	return tracks;
}

-(void)loadTracks
{
	NSString* localMusicFolderPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"localMusicFolderPath"];
	
	NSArray* tracks = [NSArray array];
	if (localMusicFolderPath)
	{
		[[[NSApp delegate] songCountLabel] setStringValue:@"Loading Local Music Songs..."];
		tracks = [self findTracksInDirectoryPath:localMusicFolderPath];
		[[[NSApp delegate] songCountLabel] setStringValue:@""];
	}
	
	[[[NSApp delegate] tracksArray] addObjectsFromArray:tracks];
}

@end
