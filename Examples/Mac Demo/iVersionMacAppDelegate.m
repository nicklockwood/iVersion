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
    //set the app and bundle ID. normally you wouldn't need to do this
    //but we need to test with an app that's actually on the store
    [iVersion sharedInstance].appStoreID = 412363063;
    [iVersion sharedInstance].applicationBundleID = @"com.charcoaldesign.RainbowBlocks";
    
    //configure iVersion. These paths are optional - if you don't set
    //them, iVersion will just get the release notes from iTunes directly
	[iVersion sharedInstance].remoteVersionsPlistURL = @"http://charcoaldesign.co.uk/iVersion/versions.plist";
	[iVersion sharedInstance].localVersionsPlistPath = @"versions.plist";
}

@end
