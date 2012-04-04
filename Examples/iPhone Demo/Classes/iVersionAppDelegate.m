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
    //set the app and bundle ID. normally you wouldn't need to do this
    //but we need to test with an app that's actually on the store
    [iVersion sharedInstance].appStoreID = 355313284;
    [iVersion sharedInstance].applicationBundleID = @"com.charcoaldesign.rainbowblocks";
    
    //configure iVersion. These paths are optional - if you don't set
    //them, iVersion will just get the release notes from iTunes directly
    [iVersion sharedInstance].remoteVersionsPlistURL = @"http://charcoaldesign.co.uk/iVersion/versions.plist";
    [iVersion sharedInstance].localVersionsPlistPath = @"versions.plist";
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
    [viewController release];
    [window release];
    [super dealloc];
}


@end
