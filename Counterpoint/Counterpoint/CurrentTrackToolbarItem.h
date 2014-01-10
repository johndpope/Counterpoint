//
//  CurrentTrackToolbarItem.h
//  Counterpoint
//
//  Created by Becky on 1/10/14.
//  Copyright (c) 2014 Beckasaurus. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CurrentTrackToolbarItemViewController;

@interface CurrentTrackToolbarItem : NSToolbarItem

@property (nonatomic, strong) IBOutlet CurrentTrackToolbarItemViewController* viewController;

@end
