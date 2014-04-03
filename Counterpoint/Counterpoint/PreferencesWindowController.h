//
//  PreferencesWindowController.h
//  Counterpoint
//
//  Created by Becky on 12/2/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SoundCloudAPI/SCAPI.h>

@interface PreferencesWindowController : NSWindowController <NSTextFieldDelegate, SCSoundCloudAPIAuthenticationDelegate>

@property (nonatomic, retain) NSOpenPanel* openPanel;

@end
