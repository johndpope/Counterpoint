//
//  CPTrack.m
//  Counterpoint
//
//  Created by Becky on 1/9/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import "CPTrack.h"

@implementation CPTrack

-(NSString*)description
{
	return [NSString stringWithFormat:@"%@ - %@", [self artist], [self title]];
}

@end
