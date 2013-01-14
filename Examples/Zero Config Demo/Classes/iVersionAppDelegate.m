//
//  iVersionAppDelegate.m
//  iVersion
//
//  Created by Nick Lockwood on 26/01/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "iVersionAppDelegate.h"
#import "iVersionViewController.h"


@implementation iVersionAppDelegate


//absolutely no configuration whatsoever!
//the app release notes are retrieved directly
//from iTunes using the app's bundle ID


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    [_window addSubview:_viewController.view];
    [_window makeKeyAndVisible];
    return YES;
}

@end
