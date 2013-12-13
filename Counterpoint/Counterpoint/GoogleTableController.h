//
//  GoogleViewController.h
//  Counterpoint
//
//  Created by Rebecca Henderson on 12/12/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GoogleMusicController;
@class AVPlayerItem;

@interface GoogleTableController : NSViewController

@property (nonatomic, strong) GoogleMusicController* googleMusicController;
@property (nonatomic, strong) IBOutlet NSArrayController* googleArrayController;
@property (nonatomic, strong) IBOutlet NSTableView* googleTable;

-(void)populateGoogleTable;
-(AVPlayerItem*)getPlayerItemForSelectedSong;

@end
