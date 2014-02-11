//
//  DurationValueTransformer.m
//  Counterpoint
//
//  Created by Becky on 2/11/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import "DurationValueTransformer.h"
//#import "CurrentTrackToolbarItemViewController.m"

@implementation DurationValueTransformer

+(Class)transformedValueClass
{
	return [NSString class];
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
