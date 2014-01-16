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

typedef NS_ENUM (NSInteger, ConnectionStage)
{
	LoginInitialRequestWithCredentials,
	LoginContinuedRequestWithAuthenticationToken,
	LoadAllTracks
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
		_finalResponse = [[NSMutableString alloc] init];
	}
	return self;
}

-(void)loadTracks
{
	NSString* username = [[NSUserDefaults standardUserDefaults] objectForKey:@"googleUsername"];
	NSString* password = [[NSUserDefaults standardUserDefaults] objectForKey:@"googlePassword"];
	
	if (!username || !password || [username isEqualToString:@""] || [password isEqualToString:@""])
		return;
		
	[[[NSApp delegate] songCountLabel] setStringValue:@"Loading Google Songs..."];
	[self loginWithUsername:username password:password];
}

-(void)finishedLoadingTracks
{
	for (NSDictionary* song in [self songArray])
	{
		CPTrack* trackObject = [[CPTrack alloc] init];
		[trackObject setTitle:song[@"title"]];
		[trackObject setAlbum:song[@"album"]];
		[trackObject setArtist:song[@"artist"]];
		[trackObject setIdString:song[@"id"]];
		[trackObject setTrackNumber:[NSNumber numberWithInteger:[song[@"trackNumber"] integerValue]]];
		
		
		NSArray* imageURLsArray = song[@"albumArtRef"];
		if (imageURLsArray && [imageURLsArray count] >= 1)
		{
			NSString* imageURLString = imageURLsArray[0][@"url"];
			[trackObject setAlbumArtworkImageURLString:imageURLString];
		}
		
		[[[NSApp delegate] tracksArray] addObject:trackObject];
	}
	[[NSApp delegate] finishedLoadingTracks];
}

-(BOOL)loginWithUsername:(NSString*)username password:(NSString*)password
{
	[self setUsername:username];
	[self setPassword:password];
	
	[self setAuthenticationToken:@""];
	[self setXtToken:@""];
	[self setNextPageToken:@""];
	[self setFinalResponse:[[NSMutableString alloc] init]];
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
	
	[self setRequestStage:LoginInitialRequestWithCredentials];
	
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
    [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@",[self authenticationToken]] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	[self setRequestStage:LoginContinuedRequestWithAuthenticationToken];
	
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (!connection)
		return NO;
	
	return YES;
}

-(BOOL)loadAllTracksMobile
{
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/sj/v1.1/trackfeed"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@",[self authenticationToken]] forHTTPHeaderField:@"Authorization"];
	
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
	
	[self setRequestStage:LoadAllTracks];
	
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
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
	if ([self requestStage] == LoginInitialRequestWithCredentials)
	{
		NSString *response = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
        NSArray *respArray = [response componentsSeparatedByString:@"\n"];
        response = [respArray objectAtIndex:2];
        response = [response stringByReplacingOccurrencesOfString:@"Auth=" withString:@""];
		[self setAuthenticationToken:response];
	}
	else if ([self requestStage] == LoginContinuedRequestWithAuthenticationToken)
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
	else if ([self requestStage] == LoadAllTracks)
	{
		NSString *response = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
		if (response)
			[self setFinalResponse:[[self finalResponse] stringByAppendingString:response]];
	}	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if ([self requestStage] == LoginInitialRequestWithCredentials)
	{
		[self continueLoginRequest];
	}
	else if ([self requestStage] == LoginContinuedRequestWithAuthenticationToken)
	{
		[self loadAllTracksMobile];
	}
	else if ([self requestStage] == LoadAllTracks)
	{
		NSError *localerror;
        NSData *jsonData = [[self finalResponse] dataUsingEncoding:NSUTF8StringEncoding];
        
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
				[self setFinalResponse:@""];
				[self loadAllTracksMobile];
			}
			else
				[self finishedLoadingTracks];
        }
	}
}

-(NSString*)getStreamUrl:(NSString*)songID
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://play.google.com/music/play?u=0&songid=%@&pt=e",songID]]];
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@",[self authenticationToken]] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSError *error;
    NSHTTPURLResponse *response;
    
    NSData *resp = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if([response statusCode] != 200)
	{
		NSLog(@"Bad response (%ld) from getStreamURL:", [response statusCode]);
		return @"";
	}
	
    NSString *test = [[NSString alloc] initWithData:resp encoding:NSUTF8StringEncoding];
    NSData *jsonData = [test dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *urlDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
	if (!urlDict)
	{
		NSLog(@"error!");
	}
    
    return urlDict[@"url"];
}

@end
