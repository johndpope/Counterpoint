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

@synthesize supportsEditingTracks = _supportsEditingTracks;
@synthesize serviceHasPlaylists = _serviceHasPlaylists;
@synthesize serviceHasTracklists = _serviceHasTracklists;
@synthesize serviceName = _serviceName;
@synthesize serviceType = _serviceType;

-(instancetype)init
{
	self = [super init];
	if (self)
	{
		_serviceName = @"Local Music";
		_serviceType = CPServiceTypeLocalMusic;
		_supportsEditingTracks = YES;
		_serviceHasPlaylists = NO;
		_serviceHasTracklists = YES;
	}
	return self;
}

-(void)login
{
	return;
}

-(void)loadTracks
{
	NSString* localMusicFolderPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"localMusicFolderPath"];
	
	NSArray* tracks = @[];
	if (localMusicFolderPath)
	{
		[[(AppDelegate*)[NSApp delegate] songCountLabel] setStringValue:@"Loading Local Music Songs..."];
		tracks = [self findTracksInDirectoryPath:localMusicFolderPath];
		[[(AppDelegate*)[NSApp delegate] songCountLabel] setStringValue:@""];
	}
	
	[[(AppDelegate*)[NSApp delegate] tracksArray] addObjectsFromArray:tracks];
}

-(CPTrack*)CPTrackFromServiceResponseDict:(NSDictionary *)responseDict
{
	CPTrack* track = [[CPTrack alloc] init];
	[track setServiceType:[self serviceType]];
	
	if (responseDict[@"filePath"])
		[track setStreamURLString:responseDict[@"filePath"]];
	if (responseDict[@"artist"])
		[track setArtist:responseDict[@"artist"]];
	if (responseDict[@"album"])
		[track setAlbum:responseDict[@"album"]];
	if (responseDict[@"title"])
		[track setTitle:responseDict[@"title"]];
	if (responseDict[@"genre"])
		[track setGenre:responseDict[@"genre"]];
	if (responseDict[@"tempo"])
		[track setBpm:@([responseDict[@"tempo"] integerValue])];
	if (responseDict[@"track number"])
		[track setTrackNumber:@([responseDict[@"track number"] integerValue])];
	if (responseDict[@"approximate duration in seconds"])
		[track setDurationMilliSeconds:@([responseDict[@"approximate duration in seconds"] integerValue]*1000)];
	
	return track;
}

-(NSArray*)findTracksInDirectoryPath:(NSString*)directoryPath
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSURL* fileURL = [NSURL URLWithString:directoryPath];
	if (!fileURL)
	{
		NSLog(@"File URL could not be created with path: %@", directoryPath);
		return nil;
	}
	
	NSDirectoryEnumerator* dirEnum = [fileManager enumeratorAtURL:fileURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error)
	{
		NSLog(@"Error creating directory enumerator for URL: %@\n Error: %@", url, error);
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
			
			NSMutableDictionary* trackDict = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)(dictionary)];
			trackDict[@"filePath"] = filePath;
			
			CFRelease (dictionary);
			theErr = AudioFileClose (audioFile);
			assert (theErr == noErr);
			
			CPTrack* track = [self CPTrackFromServiceResponseDict:trackDict];
			
			if (![tracks containsObject:track])
				[tracks addObject:track];
		}
	}
	
	return tracks;
}

@end
