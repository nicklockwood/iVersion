//
//  iVersionMacAppDelegate.h
//  iVersionMac
//
//  Created by Nick Lockwood on 06/02/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iVersion.h"


@interface iVersionMacAppDelegate : NSObject <NSApplicationDelegate, iVersionDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

- (IBAction)checkForNewVersion:(id)sender;

@end
