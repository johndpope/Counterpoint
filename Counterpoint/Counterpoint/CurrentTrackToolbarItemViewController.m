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
#import "QueuePopoverViewController.h"

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

-(void)awakeFromNib
{
	[[self queuePopoverViewController] setAppDelegate:[NSApp delegate]];
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
	CMTime newTime = CMTimeMakeWithSeconds([sender doubleValue], 1);
	[[[self appDelegate] player] seekToTime:newTime];
}

-(void)setupTrackDurationSlider
{
	AVKeyValueStatus duration = [[[[[self appDelegate] player] currentItem] asset] statusOfValueForKey:@"duration" error:nil];
	if (duration == AVKeyValueStatusLoaded)
	{
		[self updateDuration];
		[[self durationSlider] setMinValue:0.0];
		[[self durationSlider] setFloatValue:0.0];
		
		//this return value needs to be retained so it can be used when sending player the removeTimeObserver: message
		[self setPlayerTimeObserverReturnValue:[[[self appDelegate] player] addPeriodicTimeObserverForInterval:CMTimeMake(1, 1000) queue:dispatch_get_main_queue() usingBlock:^(CMTime time)
												{
													[self updateCurrentTime];
												}]];
	}
	else
	{
		[[[[[self appDelegate] player] currentItem] asset] loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^{
			dispatch_async(dispatch_get_main_queue(), ^{
				switch ([[[[[self appDelegate] player] currentItem] asset] statusOfValueForKey:@"duration" error:nil])
				{
					case AVKeyValueStatusLoaded:
					{
						[self setupTrackDurationSlider];
					}
					default:
						break;
				}
			});
		}];
	}
}

-(IBAction)showQueue:(NSToolbarItem*)queueToolbarItem
{
	[[self queuePopover] showRelativeToRect:[[self queueButton] bounds] ofView:[self queueButton] preferredEdge:NSMaxYEdge];
}

-(IBAction)shuffle:(id)sender
{
	[[NSApp delegate] shuffle:sender];
}

@end
