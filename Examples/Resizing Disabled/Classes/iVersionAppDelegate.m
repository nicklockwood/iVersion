//
//  iVersionAppDelegate.m
//  iVersion
//
//  Created by Nick Lockwood on 26/01/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "iVersionAppDelegate.h"
#import "iVersionViewController.h"
#import "iVersion.h"


@implementation iVersionAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

+ (void)initialize
{
    //set the bundle ID. normally you wouldn't need to do this
    //as it is picked up automatically from your Info.plist file
    //but we want to test with an app that's actually on the store
    [iVersion sharedInstance].applicationBundleID = @"com.charcoaldesign.rainbowblocks-free";
    
    //configure iVersion. These paths are optional - if you don't set
    //them, iVersion will just get the release notes from iTunes directly (if your app is on the store)
    [iVersion sharedInstance].remoteVersionsPlistURL = @"http://charcoaldesign.co.uk/iVersion/versions.plist";
    [iVersion sharedInstance].localVersionsPlistPath = @"versions.plist";

    //disable the alert view resizing
    //rotate the device to landscape to see what happens
    [iVersion sharedInstance].disableAlertViewResizing = YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
    return YES;
}

#pragma mark -
#pragma mark Memory management



@end
