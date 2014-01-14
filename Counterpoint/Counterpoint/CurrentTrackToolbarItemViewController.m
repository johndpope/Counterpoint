//
//  CurrentTrackToolbarItemViewController.m
//  Counterpoint
//
//  Created by Becky on 1/10/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import "CurrentTrackToolbarItemViewController.h"
#import "AppDelegate.h"
#import <CoreMedia/CoreMedia.h>

@interface CurrentTrackToolbarItemViewController ()

@end

@implementation CurrentTrackToolbarItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"CurrentTrackToolbarItemViewController" bundle:nibBundleOrNil];
    if (self)
	{
		_appDelegate = [NSApp delegate];
    }
    return self;
}

-(NSString*)getTimeValueStringFromCMTime:(CMTime)time
{
	float trackDurationSeconds = CMTimeGetSeconds(time);
	
	NSDate* durationDate = [NSDate dateWithTimeIntervalSince1970:trackDurationSeconds];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[dateFormatter setDateFormat:@"mm:ss"];
	NSString* timeString = [dateFormatter stringFromDate:durationDate];
	
	return timeString;
}

-(void)updateDuration
{
	CMTime duration = [[[[self appDelegate] player] currentItem] duration];
	
	[[self durationLabel] setStringValue:[self getTimeValueStringFromCMTime:duration]];
	
	[[self durationSlider] setMaxValue:CMTimeGetSeconds(duration)];
}

-(void)updateCurrentTime
{
	CMTime currentTime = [[[self appDelegate] player] currentTime];
	
	[[self currentTimeLabel] setStringValue:[self getTimeValueStringFromCMTime:currentTime]];
	
	[[[self durationSlider] animator] setFloatValue:CMTimeGetSeconds(currentTime)];
}

-(IBAction)seekToTime:(NSSlider*)sender
{
	CMTime newTime = CMTimeMakeWithSeconds([sender doubleValue], NSEC_PER_SEC);
	[[[self appDelegate] player] seekToTime:newTime];
}

@end
