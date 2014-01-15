//
//  CurrentlyPlayingValueTransformer.m
//  Counterpoint
//
//  Created by Becky on 1/15/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import "CurrentlyPlayingValueTransformer.h"

@implementation CurrentlyPlayingValueTransformer

+(Class)transformedValueClass
{
	return [NSImage class];
}

+(BOOL)allowsReverseTransformation
{
	return NO;
}

-(id)transformedValue:(id)value
{
	//value is BOOL of whether or not the item is the one currently playing
	if ([value boolValue])
		return [NSImage imageNamed:@"CurrentlyPlaying"];
	else
		return nil;
}

@end
