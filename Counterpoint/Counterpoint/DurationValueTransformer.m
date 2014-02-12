//
//  DurationValueTransformer.m
//  Counterpoint
//
//  Created by Becky on 2/11/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import "DurationValueTransformer.h"

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
	float trackDurationSeconds = [value floatValue]/1000;
	
	NSDate* durationDate = [NSDate dateWithTimeIntervalSince1970:trackDurationSeconds];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[dateFormatter setDateFormat:@"mm:ss"];
	NSString* timeString = [dateFormatter stringFromDate:durationDate];
	
	if ([[timeString substringToIndex:1] isEqualToString:@"0"])
	{
		timeString = [timeString substringFromIndex:1];
	}
	
	return timeString;
}

@end
