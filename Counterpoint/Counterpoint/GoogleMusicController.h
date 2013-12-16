//
//  GoogleMusicController.h
//  Counterpoint
//
//  Created by Becky on 12/11/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleMusicController : NSObject <NSURLConnectionDelegate>

@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* password;

@property (nonatomic, retain) NSString* authenticationToken;
@property (nonatomic, retain) NSString* xtToken;
@property (nonatomic, retain) NSString* continuationToken;
@property (nonatomic, retain) NSString* finalResponse;

@property (nonatomic) NSInteger requestStage;

@property (nonatomic, retain) NSMutableArray* songArray;

-(BOOL)loginWithUsername:(NSString*)username password:(NSString*)password;
-(NSString*)getStreamUrl:(NSString*)songID;

@end
