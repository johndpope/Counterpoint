//
//  PlayerToolbarItem.h
//  Counterpoint
//
//  Created by Becky on 12/20/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PlayerToolbarItemViewController;

@interface PlayerToolbarItem : NSToolbarItem

@property (nonatomic, strong) IBOutlet PlayerToolbarItemViewController* viewController;

@end
