//
//  iVersionMacAppDelegate.m
//  iVersionMac
//
//  Created by Nick Lockwood on 06/02/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "iVersionMacAppDelegate.h"


@implementation iVersionMacAppDelegate

@synthesize window;
@synthesize progressIndicator;
@synthesize textView;

+ (void)initialize
{
    //set the app and bundle ID. normally you wouldn't need to do this
    //but we need to test with an app that's actually on the store
    [iVersion sharedInstance].appStoreID = 412363063;
    [iVersion sharedInstance].applicationBundleID = @"com.charcoaldesign.RainbowBlocks";
    
	//set remote plist
	[iVersion sharedInstance].remoteVersionsPlistURL = @"http://charcoaldesign.co.uk/iVersion/versions.plist";

	//disable automatic checks
    [iVersion sharedInstance].checkAtLaunch = NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	//set myself as iVersion delegate
    //you can't do this in initialize method
	[iVersion sharedInstance].delegate = self;
}

- (IBAction)checkForNewVersion:(id)sender;
{
	//perform manual check
	[[iVersion sharedInstance] checkForNewVersion];
	[progressIndicator startAnimation:self];
}

#pragma mark -
#pragma mark iVersionDelegate methods

- (void)iVersionVersionCheckDidFailWithError:(NSError *)error
{
	[textView setString:[NSString stringWithFormat:@"Error: %@", error]];
	[progressIndicator stopAnimation:self];
}

- (void)iVersionDidNotDetectNewVersion
{
	[textView setString:@"No new version detected"];
	[progressIndicator stopAnimation:self];
}

- (void)iVersionDidDetectNewVersion:(NSString *)version details:(NSString *)versionDetails
{
	[textView setString:versionDetails];
	[progressIndicator stopAnimation:self];
}

- (BOOL)iVersionShouldDisplayNewVersion:(NSString *)version details:(NSString *)versionDetails
{
	//don't show alert
	return NO;
}

@end
