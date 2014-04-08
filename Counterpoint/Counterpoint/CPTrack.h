//
//  CPTrack.h
//  Counterpoint
//
//  Created by Becky on 1/9/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVPlayerItem;

@interface CPTrack : NSObject

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* artist;
@property (nonatomic, strong) NSString* album;
@property (nonatomic, strong) NSString* idString;
@property (nonatomic, strong) NSString* albumArtworkImageURLString;
@property (nonatomic, strong) NSImage* albumArtworkImage;
@property (nonatomic, strong) AVPlayerItem* playerItem;
@property (assign) BOOL currentlyPlaying;
@property (nonatomic, strong) NSNumber* trackNumber;
@property (nonatomic, strong) NSNumber* totalTracks;
@property (nonatomic, strong) NSNumber* discNumber;
@property (nonatomic, strong) NSNumber* rating;
@property (nonatomic, strong) NSString* genre;
@property (nonatomic, strong) NSNumber* bpm;
@property (nonatomic, strong) NSNumber* durationMilliSeconds;
@property (nonatomic, strong) NSNumber* playCount;
@property (nonatomic, strong) NSNumber* absolutePosition;
@property (nonatomic, strong) NSURL* streamURL;
@property (assign) CPServiceType serviceType;

@end
