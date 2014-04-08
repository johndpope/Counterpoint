//
//  SoundCloudController.h
//  Counterpoint
//
//  Created by Becky on 4/3/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SoundCloudAPI/SCAPI.h>

@class CPTrack;

@interface SoundCloudController : NSObject <SCSoundCloudAPIAuthenticationDelegate, SCSoundCloudAPIDelegate>

@property (nonatomic, strong) SCSoundCloudAPI* soundCloudAPI;

@property (nonatomic, strong) NSMutableArray* tracks;

-(void)login;
-(void)setup;
-(void)getUserStream;
-(NSURL*)getStreamURLForTrack:(CPTrack*)track;
-(void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent;

@end
