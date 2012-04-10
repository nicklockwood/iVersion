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
	//set remote plist. This is optional - if you don't set this
    //iVersion will just get the release notes from iTunes directly (if your app is on the store)
	[iVersion sharedInstance].remoteVersionsPlistURL = @"http://charcoaldesign.co.uk/iVersion/versions.plist";

	//disable automatic checks
    [iVersion sharedInstance].checkAtLaunch = NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	//set myself as iVersion delegate
    //you don't actually need to set this if you
    //are using the AppDelegate as your iVersion delegate
    //as that is the default iVersion delegate anyway
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
