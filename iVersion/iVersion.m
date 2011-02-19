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
NSString * const iVersionLastCheckedKey = @"iVersionLastChecked";
NSString * const iVersionLastRemindedKey = @"iVersionLastReminded";
NSString * const iVersionMacAppStoreBundleID = @"com.apple.appstore";

//note, these aren't ideal as they link to the app page, not the update page
//there may be some way to link directly to the app store updates tab, but I don't know what it is
NSString * const iVersioniOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%i";
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

@property (nonatomic, copy) NSDictionary *remoteVersionsDict;
@property (nonatomic, retain) NSError *downloadError;
@property (nonatomic, copy) NSString *lastVersion;

@end


@implementation iVersion

@synthesize remoteVersionsDict;
@synthesize downloadError;
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
@synthesize updateURL;
@synthesize delegate;


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
		
		if (&UIApplicationWillEnterForegroundNotification)
		{
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(applicationWillEnterForeground:)
														 name:UIApplicationWillEnterForegroundNotification
													   object:nil];
		}
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

- (NSURL *)updateURL
{
	if (updateURL == nil)
	{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		
		updateURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:iVersioniOSAppStoreURLFormat, appStoreID]];
		
#else
		
		updateURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:iVersionMacAppStoreURLFormat, appStoreID]];
		
#endif	
	}
	return updateURL;
}

- (NSDate *)lastChecked
{
	return 	[[NSUserDefaults standardUserDefaults] objectForKey:iVersionLastCheckedKey];
}

- (void)setLastChecked:(NSDate *)date
{
	[[NSUserDefaults standardUserDefaults] setObject:date forKey:iVersionLastCheckedKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
			
- (NSDate *)lastReminded
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:iVersionLastRemindedKey];
}

- (void)setLastReminded:(NSDate *)date
{
	[[NSUserDefaults standardUserDefaults] setObject:date forKey:iVersionLastRemindedKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)ignoredVersion
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:iVersionIgnoreVersionKey];
}

- (void)setIgnoredVersion:(NSString *)version
{
	[[NSUserDefaults standardUserDefaults] setObject:version forKey:iVersionIgnoreVersionKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[remoteVersionsDict release];
	[downloadError release];
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
	[updateURL release];
	[super dealloc];
}

#pragma mark -
#pragma mark Private methods

- (NSString *)lastVersion
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:iVersionLastVersionKey];
}

- (void)setLastVersion:(NSString *)version
{
	[[NSUserDefaults standardUserDefaults] setObject:version forKey:iVersionLastVersionKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
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
			NSString *versionsFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:localVersionsPlistPath];
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
	
	//check if data downloaded
	if (!remoteVersionsDict)
	{
		if ([(NSObject *)delegate respondsToSelector:@selector(iVersionVersionCheckFailed:)])
		{
			[delegate iVersionVersionCheckFailed:downloadError];
		}
		return;
	}
	
	//get version details
	NSString *versionDetails = [self versionDetailsSince:applicationVersion inDict:remoteVersionsDict];
	NSString *mostRecentVersion = [self mostRecentVersionInDict:remoteVersionsDict];
	if (versionDetails)
	{
		//inform delegate of new version
		if ([(NSObject *)delegate respondsToSelector:@selector(iVersionDetectedNewVersion:details:)])
		{
			[delegate iVersionDetectedNewVersion:mostRecentVersion details:versionDetails];
		}
		
		//check if ignored
		BOOL showDetails = ![self.ignoredVersion isEqualToString:mostRecentVersion] || remoteDebug;
		if (showDetails && [(NSObject *)delegate respondsToSelector:@selector(iVersionShouldDisplayNewVersion:details:)])
		{
			showDetails = [delegate iVersionShouldDisplayNewVersion:mostRecentVersion details:versionDetails];
		}
		
		//show details
		if (showDetails)
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

- (BOOL)shouldCheckForNewVersion
{
	if (remoteChecksDisabled)
	{
		return NO;
	}
	else if (remoteDebug)
	{
		//continue
	}
	else if (self.lastReminded != nil)
	{
		//reminder takes priority over check period
		if ([[NSDate date] timeIntervalSinceDate:self.lastReminded] < remindPeriod * SECONDS_IN_A_DAY)
		{
			return NO;
		}
	}
	else if (self.lastChecked != nil && [[NSDate date] timeIntervalSinceDate:self.lastChecked] < checkPeriod * SECONDS_IN_A_DAY)
	{
		return NO;
	}
	if ([(NSObject *)delegate respondsToSelector:@selector(iVersionShouldCheckForNewVersion)])
	{
		return [delegate iVersionShouldCheckForNewVersion];
	}
	return YES;
}

- (void)checkForNewVersionInBackground
{
	@synchronized (self)
	{
		if (remoteVersionsPlistURL)
		{
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			NSError *error = nil;
			NSDictionary *versions = nil;
			NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:remoteVersionsPlistURL] options:NSDataReadingUncached error:&error];
			if (data)
			{
				NSPropertyListFormat format;
				versions = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:&format error:&error];
			}
			[self performSelectorOnMainThread:@selector(setDownloadError:) withObject:error waitUntilDone:YES];
			[self performSelectorOnMainThread:@selector(setRemoteVersionsDict:) withObject:versions waitUntilDone:YES];
			[self performSelectorOnMainThread:@selector(setLastChecked:) withObject:[NSDate date] waitUntilDone:YES];
			[self performSelectorOnMainThread:@selector(downloadedVersionsData) withObject:nil waitUntilDone:YES];		
			[pool drain];
		}
	}
}

- (void)checkForNewVersion
{
	[self performSelectorInBackground:@selector(checkForNewVersionInBackground) withObject:nil];
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
	
	if (self.lastVersion != nil || showOnFirstLaunch || localDebug)
	{
		if ([applicationVersion compareVersion:self.lastVersion] == NSOrderedDescending || localDebug)
		{
			//clear reminder
			self.lastReminded = nil;
			
			//get version details
			NSString *versionDetails = [self versionDetailsSince:self.lastVersion inDict:[self localVersionsData]];
			
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
		self.lastVersion = applicationVersion;
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
		self.lastVersion = applicationVersion;
	}
	else if (buttonIndex == alertView.cancelButtonIndex)
	{
		//ignore this version
		self.ignoredVersion = [self mostRecentVersionInDict:remoteVersionsDict];
		self.lastReminded = nil;
	}
	else if (buttonIndex == 2)
	{
		//remind later
		self.lastReminded = [NSDate date];
	}
	else
	{
		//clear reminder
		self.lastReminded = nil;
		
		//go to download page
		[[UIApplication sharedApplication] openURL:self.updateURL];
	}
}

#else

- (void)localAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	//record this as last viewed release
	self.lastVersion = applicationVersion;
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
			[[NSWorkspace sharedWorkspace] performSelector:@selector(openURL:) withObject:self.updateURL afterDelay:MAC_APP_STORE_REFRESH_DELAY];
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
			self.ignoredVersion = [self mostRecentVersionInDict:remoteVersionsDict];
			self.lastReminded = nil;
			break;
		}
		case NSAlertDefaultReturn:
		{
			//clear reminder
			self.lastReminded = nil;
			
			//launch mac app store
			[[NSWorkspace sharedWorkspace] openURL:self.updateURL];
			[self openAppPageWhenAppStoreLaunched];
			break;
		}
		default:
		{
			//remind later
			self.lastReminded = [NSDate date];
		}
	}
}

#endif

- (void)applicationLaunched:(NSNotification *)notification
{
	if ([self shouldCheckForNewVersion])
	{
		[self checkForNewVersion];
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
		[self checkForNewVersion];
	}
}

@end