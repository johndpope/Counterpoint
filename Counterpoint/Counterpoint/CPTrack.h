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

@end
