//
//  SoundCloudController.m
//  Counterpoint
//
//  Created by Becky on 4/3/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import "SoundCloudController.h"
#import "CPTrack.h"
#import "AppDelegate.h"

NSString* const SoundCloudClientId = @"11b15f89e67359193cd8f89f2bc977e2";
NSString* const SoundCloudClientSecret = @"0b16bc65cf8e9c872bc98204eff28a9c";
NSString* const SoundCloudRedirectURL = @"counterpoint://soundcloud";

@implementation SoundCloudController

-(instancetype)init
{
	self = [super init];
	if (self)
	{
		_tracks = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)setup
{
	SCSoundCloudAPIConfiguration *scAPIConfig = [SCSoundCloudAPIConfiguration
												 configurationForProductionWithClientID:SoundCloudClientId
												 clientSecret:SoundCloudClientSecret
												 redirectURL:[NSURL URLWithString:SoundCloudRedirectURL]];
	
	[self setSoundCloudAPI:[[SCSoundCloudAPI alloc] initWithDelegate:self authenticationDelegate:self apiConfiguration:scAPIConfig]];
	[[self soundCloudAPI] setResponseFormat:SCResponseFormatJSON];
	
	[self _registerMyApp];
}

-(void)login
{
	[[self soundCloudAPI] checkAuthentication];
}

-(void)getUserFavorites
{
	if ([[self soundCloudAPI] isAuthenticated])
	{
		[[self tracks] removeAllObjects];
		
		[[(AppDelegate*)[NSApp delegate] songCountLabel] setStringValue:@"Loading SoundCloud Stream..."];
		[[self soundCloudAPI] performMethod:@"GET"
								 onResource:@"/me/favorites"
							 withParameters:nil
									context:@"getUserFavorites"
								   userInfo:nil];
	}
}

- (void)getUserStream
{
	if ([[self soundCloudAPI] isAuthenticated])
	{
		[[(AppDelegate*)[NSApp delegate] songCountLabel] setStringValue:@"Loading SoundCloud Stream..."];
		[[self soundCloudAPI] performMethod:@"GET"
								 onResource:@"/me/activities/tracks/affiliated?limit=500"
							 withParameters:nil
									context:@"getUserStream"
								   userInfo:nil];
	}
}

-(NSURL*)getStreamURLForTrack:(CPTrack*)track
{
	NSURL *finalURL = nil;
	if ([track streamURLString])
		finalURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@?client_id=%@", [track streamURLString], SoundCloudClientId]];
	
	return finalURL;
}

-(void)addSoundCloudFavorites:(NSArray*)favoritedTracks
{
	[[self tracks] addObjectsFromArray:favoritedTracks];
	
	for (NSDictionary* track in [self tracks])
	{
		if (![track[@"streamable"] boolValue])
			continue;
		
		CPTrack* trackObject = [[CPTrack alloc] init];
		[trackObject setTitle:track[@"title"]];
		[trackObject setAlbum:track[@"album"]];
		[trackObject setArtist:track[@"user"][@"username"]];
		[trackObject setIdString:track[@"id"]];
		[trackObject setTrackNumber:track[@"trackNumber"]];
		[trackObject setTotalTracks:track[@"totalTrackCount"]];
		[trackObject setDiscNumber:track[@"discNumber"]];
		[trackObject setRating:track[@"rating"]];
		[trackObject setGenre:track[@"genre"]];
		[trackObject setBpm:track[@"bpm"]];
		[trackObject setDurationMilliSeconds:track[@"duration"]];
		[trackObject setPlayCount:track[@"user_playback_count"]];
		[trackObject setServiceType:CPServiceTypeGoogleMusic];
		[trackObject setAlbumArtworkImageURLString:track[@"artwork_url"]];
		[trackObject setStreamURLString:track[@"stream_url"]];
		[trackObject setServiceType:CPServiceTypeSoundCloud];
		
		[[(AppDelegate*)[NSApp delegate] tracksArray] addObject:trackObject];
	}
	
	[(AppDelegate*)[NSApp delegate] finishedLoadingTracks];
}

-(void)addSoundCloudStreamTracks:(NSDictionary*)streamActivites
{
	
	[[self tracks] addObjectsFromArray:streamActivites[@"collection"]];
	
	if (streamActivites[@"next_href"])
	{
		//more to grab still so keep going
		[[self soundCloudAPI] performMethod:@"GET"
								 onResource:streamActivites[@"next_href"]
							 withParameters:nil
									context:@"getUserStream"
								   userInfo:nil];
	}
	else
	{
		for (NSDictionary* trackDict in [self tracks])
		{
			NSDictionary* track = trackDict[@"origin"];
			
			if (![track[@"streamable"] boolValue])
				continue;
			
			CPTrack* trackObject = [[CPTrack alloc] init];
			[trackObject setTitle:track[@"title"]];
			[trackObject setAlbum:track[@"album"]];
			[trackObject setArtist:track[@"user"][@"username"]];
			[trackObject setIdString:track[@"id"]];
			[trackObject setTrackNumber:track[@"trackNumber"]];
			[trackObject setTotalTracks:track[@"totalTrackCount"]];
			[trackObject setDiscNumber:track[@"discNumber"]];
			[trackObject setRating:track[@"rating"]];
			[trackObject setGenre:track[@"genre"]];
			[trackObject setBpm:track[@"bpm"]];
			[trackObject setDurationMilliSeconds:track[@"duration"]];
			[trackObject setPlayCount:track[@"user_playback_count"]];
			[trackObject setServiceType:CPServiceTypeGoogleMusic];
			[trackObject setAlbumArtworkImageURLString:track[@"artwork_url"]];
			[trackObject setStreamURLString:track[@"stream_url"]];
			[trackObject setServiceType:CPServiceTypeSoundCloud];
			
			[[(AppDelegate*)[NSApp delegate] tracksArray] addObject:trackObject];
		}
		
		[(AppDelegate*)[NSApp delegate] finishedLoadingTracks];
		
	}
}

#pragma mark URL handling

- (void)_registerMyApp;
{
	NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
	[appleEventManager setEventHandler:self andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
	
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	OSStatus result = LSSetDefaultHandlerForURLScheme((__bridge CFStringRef)SoundCloudRedirectURL, (__bridge CFStringRef)bundleID);
	if(result != noErr)
	{
		NSLog(@"could not register to \"%@\" URL scheme", SoundCloudRedirectURL);
	}
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSString* url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
	
	if([url hasPrefix:SoundCloudRedirectURL])
	{
		BOOL handled = [[self soundCloudAPI] handleRedirectURL:[NSURL URLWithString:url]];
		if (!handled)
		{
			NSLog(@"The URL (%@) could not be handled by the SoundCloud API. Maybe you want to do something with it.", url);
		}
	}
}

#pragma mark SoundCloudAPI authorization delegate

- (void)soundCloudAPIPreparedAuthorizationURL:(NSURL *)authorizationURL;
{
	[[NSWorkspace sharedWorkspace] openURL:authorizationURL];
}

- (void)soundCloudAPIDidAuthenticate;
{
	[self getUserFavorites];
}

- (void)soundCloudAPIDidResetAuthentication;
{
	//do some shit....idk what though
//	[sendRequestButton setEnabled:NO];
//	[postTestButton setEnabled:NO];
}

- (void)soundCloudAPIDidFailToGetAccessTokenWithError:(NSError *)error;
{
	if ([[error domain] isEqualToString:NSURLErrorDomain])
	{
		if (error.code == NSURLErrorNotConnectedToInternet)
		{
			[NSAlert alertWithMessageText:@"Oh noes!" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"We couldn't seem to establish an internet connection. Check you network settings and try again."];
		}
	}
	else if ([[error domain] isEqualToString:SCAPIErrorDomain])
	{
	}
	//FIXME: what should this error string really be?
//	else if ([[error domain] isEqualToString:NXOAuth2ErrorDomain])
//	{
//	}
	
	NSString *message = [NSString stringWithFormat:@"Request finished with Error: \n%@", [error localizedDescription]];
	NSLog(@"%@", message);
}

#pragma mark request delegates

- (void)soundCloudAPI:(SCSoundCloudAPI *)soundCloudAPI didFinishWithData:(NSData *)data context:(id)context userInfo:(id)userInfo;
{
	if([context isEqualToString:@"getUserStream"])
	{
		NSError* error = nil;
		NSDictionary* jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		[self addSoundCloudStreamTracks:jsonObject];
		return;
	}
	else if ([context isEqualToString:@"getUserFavorites"])
	{
		NSError* error = nil;
		NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		[self addSoundCloudFavorites:jsonArray];
		return;
	}
}

- (void)soundCloudAPI:(SCSoundCloudAPI *)soundCloudAPI didFailWithError:(NSError *)error context:(id)context userInfo:(id)userInfo;
{
	if ([[error domain] isEqualToString:NSURLErrorDomain])
	{
		if (error.code == NSURLErrorNotConnectedToInternet)
		{
			[NSAlert alertWithMessageText:@"Oh noes!" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"We couldn't seem to establish an internet connection. Check you network settings and try again."];
		}
	}
//	else if ([[error domain] isEqualToString:SCAPIErrorDomain])
//	{
//	}
//	else if ([[error domain] isEqualToString:NXOAuth2ErrorDomain])
//	{
//	}
	
	NSString *message = [NSString stringWithFormat:@"Request finished with Error: \n%@", [error localizedDescription]];
	NSLog(@"%@", message);
}

- (void)soundCloudAPI:(SCSoundCloudAPI *)soundCloudAPI didReceiveData:(NSData *)data context:(id)context userInfo:(id)userInfo;
{
	NSLog(@"Did Recieve Data");
}

- (void)soundCloudAPI:(SCSoundCloudAPI *)soundCloudAPI didReceiveBytes:(unsigned long long)loadedBytes total:(unsigned long long)totalBytes context:(id)context userInfo:(id)userInfo;
{
	NSLog(@"Did receive Bytes %qu of %qu", loadedBytes, totalBytes);
}

- (void)soundCloudAPI:(SCSoundCloudAPI *)soundCloudAPI didSendBytes:(unsigned long long)sendBytes total:(unsigned long long)totalBytes context:(id)context userInfo:(id)userInfo;
{
	NSLog(@"Did send Bytes %qu of %qu", sendBytes, totalBytes);
}


@end
