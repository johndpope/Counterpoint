//
//  GoogleMusicController.m
//  Counterpoint
//
//  Created by Becky on 12/11/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import "GoogleMusicController.h"
#import "AppDelegate.h"
#import "CPTrack.h"
#import "CPPlaylist.h"

typedef NS_ENUM (NSInteger, GoogleMusicConnectionStage)
{
	GoogleMusicConnectionStageLoginWithCredentials,
	GoogleMusicConnectionStageLoginWithAuthenticationToken,
	GoogleMusicConnectionStageLoadAllTracks,
	GoogleMusicConnectionStageLoadPlaylists,
	GoogleMusicConnectionStageLoadPlaylistEntries
};

@implementation GoogleMusicController

-(id)init
{
	self = [super init];
	if (self)
	{
		_authenticationToken = [[NSString alloc] init];
		_xtToken = [[NSString alloc] init];
		_nextPageToken = [[NSString alloc] init];
		_songArray = [[NSMutableArray alloc] init];
		_playlistsArray = [[NSMutableArray alloc] init];
		_playlistEntriesArray = [[NSMutableArray alloc] init];
		_allTracksResponse = [[NSMutableString alloc] init];
		_playlistsResponse = [[NSMutableString alloc] init];
		_playlistEntriesResponse = [[NSMutableString alloc] init];
	}
	return self;
}

-(void)loadTracks
{
	if(![[NSUserDefaults standardUserDefaults] objectForKey:@"googleMusicAuthenticationToken"])
		return;
	
	[[self songArray] removeAllObjects];
	[[[NSApp delegate] songCountLabel] setStringValue:@"Loading Google Songs..."];
	
	[self loadAllTracksMobile];
}

-(BOOL)loadAllTracksMobile
{
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/sj/v1.1/trackfeed"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"googleMusicAuthenticationToken"]] forHTTPHeaderField:@"Authorization"];
	
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	if ([self nextPageToken] && ![[self nextPageToken] isEqualToString:@""])
	{
		NSDictionary* jsonDict = @{@"start-token" : [self nextPageToken]};
		
		NSError* error = nil;
		NSData* body = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
		
		if (!body)
		{
			if (error)
			{
				NSLog(@"%@",[error description]);
				[self finishedLoadingTracks];
				return NO;
			}
		}
		else
			[request setHTTPBody:body];
	}
	
	[self setRequestStage:GoogleMusicConnectionStageLoadAllTracks];
	
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
	if (!connection)
		return NO;
	
	return YES;
}

-(void)loadPlaylists
{
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/sj/v1.1/playlistfeed"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"googleMusicAuthenticationToken"]] forHTTPHeaderField:@"Authorization"];
	
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	[self setRequestStage:GoogleMusicConnectionStageLoadPlaylists];
	
	NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
	if (!connection)
		return;
	
	return;
}

-(void)loadPlaylistEntries
{
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/sj/v1.1/plentryfeed"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"googleMusicAuthenticationToken"]] forHTTPHeaderField:@"Authorization"];
	
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	[self setRequestStage:GoogleMusicConnectionStageLoadPlaylistEntries];
	
	NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
	if (!connection)
		return;
	
	return;

}

-(void)finishedLoadingTracks
{
	[[[NSApp delegate] tracksArray] removeAllObjects];
	
	for (NSDictionary* song in [self songArray])
	{
		CPTrack* trackObject = [[CPTrack alloc] init];
		[trackObject setTitle:song[@"title"]];
		[trackObject setAlbum:song[@"album"]];
		[trackObject setArtist:song[@"artist"]];
		[trackObject setIdString:song[@"id"]];
		[trackObject setTrackNumber:song[@"trackNumber"]];
		[trackObject setTotalTracks:song[@"totalTrackCount"]];
		[trackObject setDiscNumber:song[@"discNumber"]];
		[trackObject setRating:song[@"rating"]];
		[trackObject setGenre:song[@"genre"]];
		[trackObject setBpm:song[@"beatsPerMinute"]];
		[trackObject setDurationMilliSeconds:song[@"durationMillis"]];
		[trackObject setPlayCount:song[@"playCount"]];
		[trackObject setServiceType:CPServiceTypeGoogleMusic];
		
		NSArray* imageURLsArray = song[@"albumArtRef"];
		if (imageURLsArray && [imageURLsArray count] >= 1)
		{
			NSString* imageURLString = imageURLsArray[0][@"url"];
			[trackObject setAlbumArtworkImageURLString:imageURLString];
		}
		
		[[[NSApp delegate] tracksArray] addObject:trackObject];
	}
	
	[self setAllTracksResponse:[NSMutableString string]];
	[self setNextPageToken:@""];
	
	[[NSApp delegate] finishedLoadingTracks];
	
	[self loadPlaylists];
}

-(void)finishedLoadingPlaylists
{
	[[[NSApp delegate] playlistsArray] removeAllObjects];
	
	for (NSDictionary* playlist in [self playlistsArray])
	{
		CPPlaylist* playlistObject = [[CPPlaylist alloc] init];
		[playlistObject setName:playlist[@"name"]];
		[playlistObject setIdString:playlist[@"id"]];
		[playlistObject setType:playlist[@"type"]];
		[playlistObject setShareToken:playlist[@"shareToken"]];
		
		NSArray* entries = [[self playlistEntriesArray] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = %@", @"playlistId", [playlistObject idString]]];
		[playlistObject setTracks:[NSMutableArray arrayWithArray:entries]];
							
		[[[NSApp delegate] playlistsArray] addObject:playlistObject];
	}
	
	[self setPlaylistsResponse:[NSMutableString string]];
	
	[[NSApp delegate] finishedLoadingPlaylists];
}

-(BOOL)loginWithUsername:(NSString*)username password:(NSString*)password
{
	[self setUsername:username];
	[self setPassword:password];
	
	[self setAuthenticationToken:@""];
	[self setXtToken:@""];
	[self setNextPageToken:@""];
	[self setAllTracksResponse:[[NSMutableString alloc] init]];
	[self setPlaylistsResponse:[[NSMutableString alloc] init]];
	[[self songArray] removeAllObjects];
	
	NSString *post = [NSString stringWithFormat:@"&Email=%@&Passwd=%@&service=sj",[self username],[self password]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
	
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.google.com/accounts/ClientLogin"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
	
	[self setRequestStage:GoogleMusicConnectionStageLoginWithCredentials];
	
	NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (!connection)
		return NO;
	
	return YES;
}

-(BOOL)continueLoginRequest
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://play.google.com/music/listen?u=0"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"googleMusicAuthenticationToken"]] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	[self setRequestStage:GoogleMusicConnectionStageLoginWithAuthenticationToken];
	
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (!connection)
		return NO;
	
	return YES;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	[[challenge sender] useCredential:[NSURLCredential
									   credentialWithUser:[self username]
									   password:[self password]
									   persistence:NSURLCredentialPersistencePermanent] forAuthenticationChallenge:challenge];
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	[[challenge sender] useCredential:[NSURLCredential
									   credentialWithUser:[self username]
									   password:[self password]
									   persistence:NSURLCredentialPersistencePermanent] forAuthenticationChallenge:challenge];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
	if ([self requestStage] == GoogleMusicConnectionStageLoginWithCredentials)
	{
		NSString *response = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
        NSArray *respArray = [response componentsSeparatedByString:@"\n"];
        response = [respArray objectAtIndex:2];
        response = [response stringByReplacingOccurrencesOfString:@"Auth=" withString:@""];
		[[NSUserDefaults standardUserDefaults] setObject:response forKey:@"googleMusicAuthenticationToken"];
	}
	else if ([self requestStage] == GoogleMusicConnectionStageLoginWithAuthenticationToken)
	{
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [cookieJar cookies])
        {
            if ([[cookie name] isEqualToString:@"xt"])
            {
				[self setXtToken:[cookie value]];
            }
        }
	}
	else if ([self requestStage] == GoogleMusicConnectionStageLoadAllTracks)
	{
		NSString *response = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
		if (response)
			[self setAllTracksResponse:[[self allTracksResponse] stringByAppendingString:response]];
	}
	else if ([self requestStage] == GoogleMusicConnectionStageLoadPlaylists)
	{
		NSString *response = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
		if (response)
			[self setPlaylistsResponse:[[self playlistsResponse] stringByAppendingString:response]];
	}
	else if ([self requestStage] == GoogleMusicConnectionStageLoadPlaylistEntries)
	{
		NSString *response = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
		if (response)
			[self setPlaylistEntriesResponse:[[self playlistEntriesResponse] stringByAppendingString:response]];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if ([self requestStage] == GoogleMusicConnectionStageLoginWithCredentials)
	{
		[self continueLoginRequest];
	}
	else if ([self requestStage] == GoogleMusicConnectionStageLoginWithAuthenticationToken)
	{
		[self loadAllTracksMobile];
	}
	else if ([self requestStage] == GoogleMusicConnectionStageLoadAllTracks)
	{
		NSError *localerror;
        NSData *jsonData = [[self allTracksResponse] dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *songDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&localerror];
        if (localerror)
        {
            NSLog(@"%@",[localerror description]);
        }
        else
        {
			NSArray* songs = songDict[@"data"][@"items"];
            for (NSDictionary *song in songs)
            {
				[[self songArray] addObject:song];
            }
			
			NSString* continuationToken = songDict[@"nextPageToken"];
			if (continuationToken && ![continuationToken isEqualToString:@""])
			{
				[self setNextPageToken:continuationToken];
				[self setAllTracksResponse:@""];
				[self loadAllTracksMobile];
			}
			else
				[self finishedLoadingTracks];
        }
	}
	else if ([self requestStage] == GoogleMusicConnectionStageLoadPlaylists)
	{
		NSError *localerror;
        NSData *jsonData = [[self playlistsResponse] dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *playlists = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&localerror];
		
		for (NSDictionary* playlist in playlists[@"data"][@"items"])
		{
			[[self playlistsArray] addObject:playlist];
		}
		
		[self loadPlaylistEntries];
	}
	else if ([self requestStage] == GoogleMusicConnectionStageLoadPlaylistEntries)
	{
		NSError *localerror;
        NSData *jsonData = [[self playlistEntriesResponse] dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *playlistEntries = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&localerror];
		
		for (NSDictionary* playlistEntry in playlistEntries[@"data"][@"items"])
		{
			[[self playlistEntriesArray] addObject:playlistEntry];
		}
		
		[self finishedLoadingPlaylists];
	}
}

-(NSString*)getStreamUrl:(NSString*)songID
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://play.google.com/music/play?u=0&songid=%@&pt=e",songID]]];
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"googleMusicAuthenticationToken"]] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSError *error;
    NSHTTPURLResponse *response;
    
    NSData *resp = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if([response statusCode] != 200)
	{
		NSLog(@"Error code (%ld) when sending request from getStreamURL:", [response statusCode]);
		return @"";
	}
	
    NSString *test = [[NSString alloc] initWithData:resp encoding:NSUTF8StringEncoding];
    NSData *jsonData = [test dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *urlDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
	if (!urlDict)
		NSLog(@"Error serializing JSON object from data.");
	
	if (!urlDict[@"url"])
		NSLog(@"No URL returned for song id: %@. \nResponse dict: %@", songID, urlDict);
    
    return urlDict[@"url"];
}

@end
