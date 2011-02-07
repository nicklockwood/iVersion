//
//  iVersion.m
//  iVersion
//
//  Created by Nick Lockwood on 26/01/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "iVersion.h"


NSString * const iVersionLastVersionKey = @"iVersionLastVersionChecked";
NSString * const iVersionIgnoreVersionKey = @"iVersionIgnoreVersion";
NSString * const iVersionLastCheckedVersionKey = @"iVersionLastCheckedVersion";
NSString * const iVersionLastRemindedVersionKey = @"iVersionLastRemindedVersion";
NSString * const iVersionMacAppStoreBundleID = @"com.apple.appstore";

//note, these aren't ideal as they link to the app page, not the update page
//there may be some way to link directly to the app store updates tab, but I don't know what it is
NSString * const iVersioniPhoneAppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%i";
NSString * const iVersioniPadAppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%i";
NSString * const iVersionMacAppStoreURLFormat = @"macappstore://itunes.apple.com/app/id%i";

static iVersion *sharedInstance = nil;


#define SECONDS_IN_A_DAY 86400.0
#define MAC_APP_STORE_REFRESH_DELAY 2


@implementation NSString(iVersion)

- (NSComparisonResult)compareVersion:(NSString *)version
{
	NSArray *thisVersionParts = [self componentsSeparatedByString:@"."];
	NSArray *versionParts = [version componentsSeparatedByString:@"."];
	NSUInteger count = MIN([thisVersionParts count], [versionParts count]);
	NSUInteger i;
	for (i = 0; i < count; i++)
	{
		NSUInteger thisPart = [[thisVersionParts objectAtIndex:i] integerValue];
		NSUInteger part = [[versionParts objectAtIndex:i] integerValue];
		if (thisPart > part)
		{
			return NSOrderedDescending; //version is older
		}
		else if (thisPart < part)
		{
			return NSOrderedAscending; //version is newer
		}
	}
	if ([thisVersionParts count] > [versionParts count])
	{
		return NSOrderedDescending; //version is older
	}
	else if ([thisVersionParts count] < [versionParts count])
	{
		return NSOrderedAscending; //version is newer
	}
	return NSOrderedSame; //version is the same
}

- (NSComparisonResult)compareVersionDescending:(NSString *)version
{
	NSComparisonResult result = [self compareVersion:version];
	if (result == NSOrderedDescending)
	{
		return NSOrderedAscending;
	}
	else if (result == NSOrderedAscending)
	{
		return NSOrderedDescending;
	}
	return NSOrderedSame;
}

@end


@interface iVersion()

@property (nonatomic, retain) NSDictionary *remoteVersionsData;

@end


@implementation iVersion

@synthesize remoteVersionsData;
@synthesize appStoreID;
@synthesize remoteVersionsPlistURL;
@synthesize localVersionsPlistPath;
@synthesize applicationName;
@synthesize applicationVersion;
@synthesize showOnFirstLaunch;
@synthesize groupNotesByVersion;
@synthesize checkPeriod;
@synthesize remindPeriod;
@synthesize newInThisVersionTitle;
@synthesize newVersionAvailableTitle;
@synthesize versionLabelFormat;
@synthesize okButtonLabel;
@synthesize ignoreButtonLabel;
@synthesize remindButtonLabel;
@synthesize downloadButtonLabel;
@synthesize localChecksDisabled;
@synthesize remoteChecksDisabled;
@synthesize localDebug;
@synthesize remoteDebug;

#pragma mark -
#pragma mark Lifecycle methods

+ (iVersion *)sharedInstance
{
	if (sharedInstance == nil)
	{
		sharedInstance = [[iVersion alloc] init];
	}
	return sharedInstance;
}

- (iVersion *)init
{
	if ((self = [super init]))
	{
		
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		
		//register for iphone application events
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(applicationLaunched:)
													 name:UIApplicationDidFinishLaunchingNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(applicationWillEnterForeground:)
													 name:UIApplicationWillEnterForegroundNotification
												   object:nil];
#else
		//register for mac application events
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(applicationLaunched:)
													 name:NSApplicationDidFinishLaunchingNotification
												   object:nil];
#endif
		//application name and version
		self.applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
		self.applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];

		//default settings
		showOnFirstLaunch = NO;
		groupNotesByVersion = YES;
		checkPeriod = 0.5;
		remindPeriod = 1;
		
		//default message text, don't edit these here; if you want to provide your
		//own message text then configure them using the setters/getters
		self.newInThisVersionTitle = @"New in this version";
		self.newVersionAvailableTitle = nil; //set lazily so that appname can be included
		self.versionLabelFormat = @"Version %@";
		self.okButtonLabel = @"OK";
		self.ignoreButtonLabel = @"Ignore";
		self.remindButtonLabel = @"Remind Me Later";
		self.downloadButtonLabel = @"Download";
	}
	return self;
}

- (NSString *)newVersionAvailableTitle
{
	if (newVersionAvailableTitle == nil)
	{
		self.newVersionAvailableTitle = [NSString stringWithFormat:@"A new version of %@ is available to download", applicationName];
	}
	return newVersionAvailableTitle;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[remoteVersionsData release];
	[remoteVersionsPlistURL release];
	[localVersionsPlistPath release];
	[applicationName release];
	[applicationVersion release];
	[newInThisVersionTitle release];
	[newVersionAvailableTitle release];
	[versionLabelFormat release];
	[okButtonLabel release];
	[ignoreButtonLabel release];
	[remindButtonLabel release];
	[downloadButtonLabel release];
	[super dealloc];
}

#pragma mark -
#pragma mark Private methods

- (NSURL *)updateURL
{
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		return [NSURL URLWithString:[NSString stringWithFormat:iVersioniPadAppStoreURLFormat, appStoreID]];
	}
	else
	{
		return [NSURL URLWithString:[NSString stringWithFormat:iVersioniPhoneAppStoreURLFormat, appStoreID]];
	}
	
#else
	
	return [NSURL URLWithString:[NSString stringWithFormat:iVersionMacAppStoreURLFormat, appStoreID]];
	
#endif
	
}

- (NSDictionary *)localVersionsData
{
	static NSDictionary *versionsData = nil;
	if (versionsData == nil)
	{
		if (localVersionsPlistPath == nil)
		{
			versionsData = [[NSDictionary alloc] init]; //empty dictionary
		}
		else
		{
			NSString *versionsFile = [[NSBundle mainBundle] pathForResource:localVersionsPlistPath ofType:@""];
			versionsData = [[NSDictionary alloc] initWithContentsOfFile:versionsFile];
		}
	}
	return versionsData;
}

- (NSString *)mostRecentVersionInDict:(NSDictionary *)dict
{
	return [[[dict allKeys] sortedArrayUsingSelector:@selector(compareVersion:)] lastObject];
}

- (NSString *)versionDetails:(NSString *)version inDict:(NSDictionary *)dict
{
	NSArray *versionData = [dict objectForKey:version];
	return [versionData componentsJoinedByString:@"\n\n"];
}

- (NSString *)versionDetailsSince:(NSString *)lastVersion inDict:(NSDictionary *)dict
{
	if (localDebug)
	{
		lastVersion = @"0";
	}
	BOOL newVersionFound = NO;
	NSMutableString *versionDetails = [NSMutableString stringWithString:@""];
	NSArray *versions = [[dict allKeys] sortedArrayUsingSelector:@selector(compareVersionDescending:)];
	for (NSString *version in versions)
	{
		if ([version compareVersion:lastVersion] == NSOrderedDescending)
		{
			newVersionFound = YES;
			if (groupNotesByVersion)
			{
				[versionDetails appendFormat:versionLabelFormat, version];
				[versionDetails appendString:@"\n\n"];
			}
			[versionDetails appendString:[self versionDetails:version inDict:dict]];
			[versionDetails appendString:@"\n\n"];
		}
	}
	return newVersionFound? [versionDetails stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]: nil;
}

- (void)downloadedVersionsData
{
	
#ifndef __IPHONE_OS_VERSION_MAX_ALLOWED
	
	//only show when main window is available
	if (![[NSApplication sharedApplication] mainWindow])
	{
		[self performSelector:@selector(downloadedVersionsData) withObject:nil afterDelay:0.5];
		return;
	}
	
#endif
	
	//get version details
	NSString *versionDetails = [self versionDetailsSince:applicationVersion inDict:remoteVersionsData];
	
	//check if ignored
	NSString *ignoredVersion = [[NSUserDefaults standardUserDefaults] objectForKey:iVersionIgnoreVersionKey];
	if (![ignoredVersion isEqualToString:[self mostRecentVersionInDict:remoteVersionsData]] || remoteDebug)
	{
		//show details
		if (versionDetails)
		{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.newVersionAvailableTitle
															message:versionDetails
														   delegate:self
												  cancelButtonTitle:ignoreButtonLabel
												  otherButtonTitles:downloadButtonLabel, nil];
			if (remindButtonLabel)
			{
				[alert addButtonWithTitle:remindButtonLabel];
			}
			
			[alert show];
			[alert release];
#else
			NSAlert *alert = [NSAlert alertWithMessageText:self.newVersionAvailableTitle
											 defaultButton:downloadButtonLabel
										   alternateButton:ignoreButtonLabel
											   otherButton:nil
								 informativeTextWithFormat:versionDetails];	
			
			if (remindButtonLabel)
			{
				[alert addButtonWithTitle:remindButtonLabel];
			}
			
			[alert beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow]
							  modalDelegate:self
							 didEndSelector:@selector(remoteAlertDidEnd:returnCode:contextInfo:)
								contextInfo:nil];
#endif
		}
	}
}

- (void)updateLastCheckedDate
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:iVersionLastCheckedVersionKey];
}

- (BOOL)shouldCheckForNewVersion
{
	if (remoteChecksDisabled)
	{
		return NO;
	}
	if (remoteDebug)
	{
		return YES;
	}
	NSDate *lastReminded = [[NSUserDefaults standardUserDefaults] objectForKey:iVersionLastRemindedVersionKey];
	if (lastReminded != nil)
	{
		//reminder takes priority over check period
		return ([[NSDate date] timeIntervalSinceDate:lastReminded] >= (float)remindPeriod * SECONDS_IN_A_DAY);
	}
	NSDate *lastChecked = [[NSUserDefaults standardUserDefaults] objectForKey:iVersionLastCheckedVersionKey];
	if (lastChecked == nil || [[NSDate date] timeIntervalSinceDate:lastChecked] >= (float)checkPeriod * SECONDS_IN_A_DAY)
	{
		return YES;
	}
	return NO;
}

- (void)checkForNewVersion
{
	@synchronized (self)
	{
		if (remoteVersionsPlistURL)
		{
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			NSDictionary *versionsDetails = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:remoteVersionsPlistURL]];
			[self performSelectorOnMainThread:@selector(setRemoteVersionsData:) withObject:versionsDetails waitUntilDone:YES];
			[self performSelectorOnMainThread:@selector(updateLastCheckedDate) withObject:nil waitUntilDone:YES];
			[self performSelectorOnMainThread:@selector(downloadedVersionsData) withObject:nil waitUntilDone:YES];
			[pool drain];
		}
	}
}

- (void)checkIfNewVersion
{
	
#ifndef __IPHONE_OS_VERSION_MAX_ALLOWED
	
	//only show when main window is available
	if (![[NSApplication sharedApplication] mainWindow])
	{
		[self performSelector:@selector(checkIfNewVersion) withObject:nil afterDelay:0.5];
		return;
	}
	
#endif
	
	NSString *lastVersion = [[NSUserDefaults standardUserDefaults] objectForKey:iVersionLastVersionKey];
	if (lastVersion != nil || showOnFirstLaunch || localDebug)
	{
		if ([applicationVersion compareVersion:lastVersion] == NSOrderedDescending || localDebug)
		{
			//clear reminder
			[[NSUserDefaults standardUserDefaults] setObject:nil forKey:iVersionLastRemindedVersionKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			//get version details
			NSString *versionDetails = [self versionDetailsSince:lastVersion inDict:[self localVersionsData]];
			
			//show details
			if (versionDetails)
			{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
				
				[[[[UIAlertView alloc] initWithTitle:newInThisVersionTitle
											 message:versionDetails
											delegate:self
								   cancelButtonTitle:okButtonLabel
								   otherButtonTitles:nil] autorelease] show];			
#else
				NSAlert *alert = [NSAlert alertWithMessageText:newInThisVersionTitle
												 defaultButton:okButtonLabel
											   alternateButton:nil
												   otherButton:nil
									 informativeTextWithFormat:versionDetails];	
				
				[alert beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow]
								  modalDelegate:self
								 didEndSelector:@selector(localAlertDidEnd:returnCode:contextInfo:)
									contextInfo:nil];
#endif
			}
		}
	}
	else
	{
		//record this as last viewed release
		[[NSUserDefaults standardUserDefaults] setObject:applicationVersion forKey:iVersionLastVersionKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if ([alertView.title isEqualToString:newInThisVersionTitle])
	{
		//record this as last viewed release
		[[NSUserDefaults standardUserDefaults] setObject:applicationVersion forKey:iVersionLastVersionKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	else if (buttonIndex == alertView.cancelButtonIndex)
	{
		//ignore this version
		[[NSUserDefaults standardUserDefaults] setObject:[self mostRecentVersionInDict:remoteVersionsData] forKey:iVersionIgnoreVersionKey];
		[[NSUserDefaults standardUserDefaults] setObject:nil forKey:iVersionLastRemindedVersionKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	else if (buttonIndex == 2)
	{
		//remind later
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:iVersionLastRemindedVersionKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	else
	{
		//clear reminder
		[[NSUserDefaults standardUserDefaults] setObject:nil forKey:iVersionLastRemindedVersionKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		//go to download page
		[[UIApplication sharedApplication] openURL:[self updateURL]];
	}
	
}

#else

- (void)localAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	//record this as last viewed release
	[[NSUserDefaults standardUserDefaults] setObject:applicationVersion forKey:iVersionLastVersionKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)openAppPageWhenAppStoreLaunched
{
	//check if app store is running
    ProcessSerialNumber psn = { kNoProcess, kNoProcess };
    while (GetNextProcess(&psn) == noErr)
	{
        CFDictionaryRef cfDict = ProcessInformationCopyDictionary(&psn,  kProcessDictionaryIncludeAllInformationMask);
		NSString *bundleID = [(NSDictionary *)cfDict objectForKey:(NSString *)kCFBundleIdentifierKey];
		if ([iVersionMacAppStoreBundleID isEqualToString:bundleID])
		{
			//open app page
			[[NSWorkspace sharedWorkspace] performSelector:@selector(openURL:) withObject:[self updateURL] afterDelay:MAC_APP_STORE_REFRESH_DELAY];
			CFRelease(cfDict);
			return;
		}
		CFRelease(cfDict);
    }
	
	//try again
	[self performSelector:@selector(openAppPageWhenAppStoreLaunched) withObject:nil afterDelay:0];
}

- (void)remoteAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	switch (returnCode)
	{
		case NSAlertAlternateReturn:
		{
			//ignore this version
			[[NSUserDefaults standardUserDefaults] setObject:[self mostRecentVersionInDict:remoteVersionsData] forKey:iVersionIgnoreVersionKey];
			[[NSUserDefaults standardUserDefaults] setObject:nil forKey:iVersionLastRemindedVersionKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
			break;
		}
		case NSAlertDefaultReturn:
		{
			//clear reminder
			[[NSUserDefaults standardUserDefaults] setObject:nil forKey:iVersionLastRemindedVersionKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			//launch mac app store
			[[NSWorkspace sharedWorkspace] openURL:[self updateURL]];
			[self openAppPageWhenAppStoreLaunched];
			break;
		}
		default:
		{
			//remind later
			[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:iVersionLastRemindedVersionKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	}
}

#endif

- (void)applicationLaunched:(NSNotification *)notification
{
	if ([self shouldCheckForNewVersion])
	{
		[self performSelectorInBackground:@selector(checkForNewVersion) withObject:nil];
	}
	if (!localChecksDisabled)
	{
		[self checkIfNewVersion];
	}
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
	if ([self shouldCheckForNewVersion])
	{
		[self performSelectorInBackground:@selector(checkForNewVersion) withObject:nil];
	}
}

@end