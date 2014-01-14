//
//  NSAnimatedSlider.m
//  Counterpoint
//
//  Created by Becky on 1/14/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import "NSAnimatedSlider.h"
#import <QuartzCore/QuartzCore.h>

@implementation NSAnimatedSlider

+ (id)defaultAnimationForKey:(NSString *)key
{
    if ([key isEqualToString:@"floatValue"]) {
        return [CABasicAnimation animation];
    } else {
        return [super defaultAnimationForKey:key];
    }
}

@end
