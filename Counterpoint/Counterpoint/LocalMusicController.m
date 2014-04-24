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
	
	NSDirectoryEnumerator* dirEnum = [fileManager enumeratorAtURL:fileURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
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
			
			AudioFileID audioFile;
			OSStatus theErr = noErr;
			theErr = AudioFileOpenURL((__bridge CFURLRef)file,
									  kAudioFileReadPermission,
									  0,
									  &audioFile);
			
			assert (theErr == noErr);
			UInt32 dictionarySize = 0;
			theErr = AudioFileGetPropertyInfo (audioFile,
											   kAudioFilePropertyInfoDictionary,
											   &dictionarySize,
											   0);
			assert (theErr == noErr);
			CFDictionaryRef dictionary;
			theErr = AudioFileGetProperty (audioFile,
										   kAudioFilePropertyInfoDictionary,
										   &dictionarySize,
										   &dictionary);
			assert (theErr == noErr);
			
			NSDictionary* trackDict = [NSDictionary dictionaryWithDictionary:(__bridge NSDictionary *)(dictionary)];
			
			if (trackDict[@"artist"])
				[track setArtist:trackDict[@"artist"]];
			if (trackDict[@"album"])
				[track setAlbum:trackDict[@"album"]];
			if (trackDict[@"title"])
				[track setTitle:trackDict[@"title"]];
			if (trackDict[@"genre"])
				[track setGenre:trackDict[@"genre"]];
			if (trackDict[@"tempo"])
				[track setBpm:[NSNumber numberWithInteger:[trackDict[@"tempo"] integerValue]]];
			if (trackDict[@"track number"])
				[track setTrackNumber:[NSNumber numberWithInteger:[trackDict[@"track number"] integerValue]]];
			if (trackDict[@"approximate duration in seconds"])
				[track setDurationMilliSeconds:[NSNumber numberWithInteger:([trackDict[@"approximate duration in seconds"] integerValue]*1000)]];
			
			CFRelease (dictionary);
			theErr = AudioFileClose (audioFile);
			assert (theErr == noErr);
			
			if (![tracks containsObject:track])
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
