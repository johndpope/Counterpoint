//
//  SoundCloudController.m
//  Counterpoint
//
//  Created by Becky on 4/3/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import "SoundCloudController.h"

NSString* const SoundCloudClientId = @"11b15f89e67359193cd8f89f2bc977e2";
NSString* const SoundCloudClientSecret = @"0b16bc65cf8e9c872bc98204eff28a9c";
NSString* const SoundCloudRedirectURL = @"counterpoint://soundcloud";
//http://iosdevelopertips.com/cocoa/launching-your-own-application-via-a-custom-url-scheme.html

@implementation SoundCloudController

-(id)init
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}

-(void)awakeFromNib
{
	SCSoundCloudAPIConfiguration *scAPIConfig = [SCSoundCloudAPIConfiguration configurationForProductionWithClientID:SoundCloudClientId
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

#pragma mark URL handling

- (void)_registerMyApp;
{
	NSAppleEventManager *em = [NSAppleEventManager sharedAppleEventManager];
	[em setEventHandler:self
			andSelector:@selector(getUrl:withReplyEvent:)
		  forEventClass:kInternetEventClass
			 andEventID:kAEGetURL];
	
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	OSStatus result = LSSetDefaultHandlerForURLScheme((CFStringRef)@"x-wrapper-test", (__bridge CFStringRef)bundleID);
	if(result != noErr) {
		NSLog(@"could not register to \"x-wrapper-test\" URL scheme");
	}
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	// Get the URL
	NSString *urlStr = [[event paramDescriptorForKeyword:keyDirectObject]
						stringValue];
	
	if([urlStr hasPrefix:SoundCloudRedirectURL]) {
		NSLog(@"handling oauth callback");
		NSURL *url = [NSURL URLWithString:urlStr];
		[[self soundCloudAPI] handleRedirectURL:url];
	}
}

#pragma mark SoundCloudAPI authorization delegate

- (void)soundCloudAPIPreparedAuthorizationURL:(NSURL *)authorizationURL;
{
	[[NSWorkspace sharedWorkspace] openURL:authorizationURL];
}

- (void)soundCloudAPIDidAuthenticate;
{
	//load stream
	[self getUserStream];
}

- (void)getUserStream
{
	[[self soundCloudAPI] performMethod:@"GET"
							 onResource:@"/me/activities/tracks/affiliated"
						 withParameters:nil
								context:@"getUserStream"
							   userInfo:nil];
}

-(void)addSoundCloudStreamTracks:(NSArray*)streamActivites
{
	;
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
		id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		[self addSoundCloudStreamTracks:jsonObject];
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
