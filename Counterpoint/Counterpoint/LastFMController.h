//
//  LastFMController.h
//  Counterpoint
//
//  Created by Rebecca Henderson on 2/12/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CPTrack;

const NSString* lastFMApiKey;
const NSString* lastFMSecretKey;

@interface LastFMController : NSObject <NSURLConnectionDelegate>

-(void)requestMobileSession;
-(void)scrobbleCPTrack:(CPTrack*)track;

@end
