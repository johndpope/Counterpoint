//
//  LocalMusicController.h
//  Counterpoint
//
//  Created by Becky on 4/23/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPServiceProtocol.h"

@interface LocalMusicController : NSObject <CPServiceProtocol>

-(void)loadTracks;

@end
