//
//  QueuePopoverViewController.h
//  Counterpoint
//
//  Created by Becky on 12/18/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QueuePopoverViewController : NSViewController

@property (nonatomic, retain) IBOutlet NSTableView* queueTableView;

@property (nonatomic, retain) IBOutlet NSArrayController* queueArrayController;

@end