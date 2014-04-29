//
//  CPServiceProtocol.h
//  Counterpoint
//
//  Created by Becky on 4/29/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CPTrack;

@protocol CPServiceProtocol <NSObject>

@required

@property (assign) BOOL serviceHasTracklists;
@property (assign) BOOL serviceHasPlaylists;
@property (assign) BOOL supportsEditingTracks;

@property (strong) NSString* serviceName;
@property (assign) CPServiceType serviceType;

-(void)login;

@optional

-(void)loadPlaylists;
-(void)loadTracks;
-(NSURL*)URLForStreamWithTrack:(CPTrack*)track;
-(CPTrack*)CPTrackFromServiceResponseDict:(NSDictionary*)responseDict;
-(void)incrementPlayCountForTrack:(CPTrack*)track;
-(void)likeTrack:(CPTrack*)track;
-(void)editTrackInfoWithNewTrackInfo:(CPTrack*)newTrackInfo;

@end
