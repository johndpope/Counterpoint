//
//  CPPlaylist.h
//  Counterpoint
//
//  Created by Becky on 3/24/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPPlaylist : NSObject

@property (nonatomic, strong) NSString* idString;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* shareToken;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSMutableArray* tracks;

@end
