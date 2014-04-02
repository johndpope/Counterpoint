//
//  NSArray+CPNSArray.m
//  Counterpoint
//
//  Created by Becky on 4/1/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import "NSArray+CPNSArray.h"

@implementation NSArray (CPNSArray)

-(NSString*)commaSeparatedQuotedStringValues
{
	BOOL valid = NO;
	NSMutableString *string = [NSMutableString string];
	
	for (id object in self)
	{
		if (valid)
			[string appendString:@", "];
		
		[string appendFormat:@"%@", object];
		
		valid = YES;
	}
	
	return (valid) ? string : nil;
}

@end
