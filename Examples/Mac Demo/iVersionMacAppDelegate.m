//
//  iVersionMacAppDelegate.m
//  iVersionMac
//
//  Created by Nick Lockwood on 06/02/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "iVersionMacAppDelegate.h"
#import "iVersion.h"


@implementation iVersionMacAppDelegate

@synthesize window;

+ (void)initialize
{
	//configure iVersion
	[iVersion sharedInstance].appStoreID = 412363063;
	[iVersion sharedInstance].remoteVersionsPlistURL = @"http://charcoaldesign.co.uk/iVersion/versions.plist";
	[iVersion sharedInstance].localVersionsPlistPath = @"versions.plist";
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

@end
