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
	//configure iVersion
	[iVersion sharedInstance].appStoreID = 412363063;
	[iVersion sharedInstance].remoteVersionsPlistURL = @"http://charcoaldesign.co.uk/iVersion/versions.plist";
	[iVersion sharedInstance].localVersionsPlistPath = @"versions.plist";
	[iVersion sharedInstance].remoteChecksDisabled = YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	//set myself as iVersion delegate
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

- (void)iVersionVersionCheckFailed:(NSError *)error
{
	[textView setString:[NSString stringWithFormat:@"Error: %@", error]];
	[progressIndicator stopAnimation:self];
}

- (void)iVersionDidNotDetectNewVersion
{
	[textView setString:@"No new version detected"];
	[progressIndicator stopAnimation:self];
}

- (void)iVersionDetectedNewVersion:(NSString *)version details:(NSString *)versionDetails
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
