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
NSString* const SoundCloudRedirectURL = @"Counterpoint://";
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
}

@end
