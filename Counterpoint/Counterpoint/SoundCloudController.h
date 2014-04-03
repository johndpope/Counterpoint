//
//  SoundCloudController.h
//  Counterpoint
//
//  Created by Becky on 4/3/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SoundCloudAPI/SCAPI.h>

@interface SoundCloudController : NSObject <SCSoundCloudAPIAuthenticationDelegate, SCSoundCloudAPIDelegate>

@property (nonatomic, strong) SCSoundCloudAPI* soundCloudAPI;

@end
