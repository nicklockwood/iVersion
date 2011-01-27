//
//  iVersion.m
//  iVersion
//
//  Created by Nick Lockwood on 26/01/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "iVersion.h"


NSString * const iVersionLastVersionKey = @"iVersionLastVersionChecked";
NSString * const iVersionIgnoreVersionKey = @"iVersionIgnoreVersionKey";


static iVersion *sharedInstance = nil;


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

+ (iVersion *)sharedInstance
{
	if (sharedInstance == nil)
	{
		sharedInstance = [[iVersion alloc] init];
	}
	return sharedInstance;
}

- (NSString *)thisVersion
{
	static NSString *thisVersion = nil;
	if (thisVersion == nil)
	{
		thisVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey] retain];
	}
	return thisVersion;
}

- (NSDictionary *)localVersionsData
{
	static NSDictionary *versionsData = nil;
	if (versionsData == nil)
	{
		NSString *versionsFile = [[NSBundle mainBundle] pathForResource:IVERSION_LOCAL_VERSIONS_FILE ofType:@""];
		versionsData = [[NSDictionary alloc] initWithContentsOfFile:versionsFile];
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
	lastVersion = (IVERSION_LOCAL_DEBUG)? @"1.0": lastVersion;
	NSMutableString *versionDetails = [NSMutableString stringWithString:@""];
	NSArray *versions = [[dict allKeys] sortedArrayUsingSelector:@selector(compareVersionDescending:)];
	for (NSString *version in versions)
	{
		if ([version compareVersion:lastVersion] == NSOrderedDescending)
		{
			if (IVERSION_GROUP_NOTES_BY_VERSION)
			{
				[versionDetails appendFormat:@"Version %@\n\n", version];
			}
			[versionDetails appendString:[self versionDetails:version inDict:dict]];
			[versionDetails appendString:@"\n\n"];
		}
	}
	return [versionDetails stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

- (void)downloadedVersionsData
{
	//get version details
	NSString *versionDetails = [self versionDetailsSince:[self thisVersion] inDict:remoteVersionsData];
	
	//check if ignored
	NSString *ignoredVersion = [[NSUserDefaults standardUserDefaults] objectForKey:iVersionIgnoreVersionKey];
	if (![ignoredVersion isEqualToString:[self mostRecentVersionInDict:remoteVersionsData]] || IVERSION_REMOTE_DEBUG)
	{
		//show details
		if (versionDetails && ![versionDetails isEqualToString:@""])
		{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
			
			[[[[UIAlertView alloc] initWithTitle:IVERSION_NEW_VERSION_AVAILABLE_TITLE
										 message:versionDetails
										delegate:self
							   cancelButtonTitle:IVERSION_IGNORE_BUTTON
							   otherButtonTitles:IVERSION_DOWNLOAD_BUTTON, nil] autorelease] show];
#else
			NSAlert *alert = [NSAlert alertWithMessageText:IVERSION_NEW_VERSION_AVAILABLE_TITLE
											 defaultButton:IVERSION_DOWNLOAD_BUTTON
										   alternateButton:IVERSION_IGNORE_BUTTON
											   otherButton:nil
								 informativeTextWithFormat:versionDetails];	
			
			[alert beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow]
							  modalDelegate:self
							 didEndSelector:@selector(remoteAlertDidEnd:returnCode:contextInfo:)
								contextInfo:nil];
#endif
		}
	}
}

- (void)checkForNewVersion
{
	@synchronized (self)
	{
		if (IVERSION_REMOTE_VERSIONS_URL)
		{
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			NSDictionary *versionsDetails = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:IVERSION_REMOTE_VERSIONS_URL]];
			[self performSelectorOnMainThread:@selector(setRemoteVersionsData:) withObject:versionsDetails waitUntilDone:YES];
			[self performSelectorOnMainThread:@selector(downloadedVersionsData) withObject:nil waitUntilDone:YES];
			[pool drain];
		}
	}
}

- (void)checkIfNewVersion
{
	NSString *lastVersion = [[NSUserDefaults standardUserDefaults] objectForKey:iVersionLastVersionKey];
	if (lastVersion != nil || IVERSION_SHOW_ON_FIRST_LAUNCH || IVERSION_LOCAL_DEBUG)
	{
		if ([[self thisVersion] compareVersion:lastVersion] == NSOrderedDescending || IVERSION_LOCAL_DEBUG)
		{
			//get version details
			NSString *versionDetails = [self versionDetailsSince:lastVersion inDict:[self localVersionsData]];
			
			//show details
			if (versionDetails && ![versionDetails isEqualToString:@""])
			{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
				
				[[[[UIAlertView alloc] initWithTitle:IVERSION_NEW_IN_THIS_VERSION_TITLE
											 message:versionDetails
											delegate:self
								   cancelButtonTitle:IVERSION_OK_BUTTON
								   otherButtonTitles:nil] autorelease] show];			
#else
				NSAlert *alert = [NSAlert alertWithMessageText:IVERSION_NEW_IN_THIS_VERSION_TITLE
												 defaultButton:IVERSION_OK_BUTTON
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
		[[NSUserDefaults standardUserDefaults] setObject:[self thisVersion] forKey:iVersionLastVersionKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)dealloc
{
	[remoteVersionsData release];
	[super dealloc];
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if ([alertView.title isEqualToString:IVERSION_NEW_IN_THIS_VERSION_TITLE])
	{
		//record this as last viewed release
		[[NSUserDefaults standardUserDefaults] setObject:[self thisVersion] forKey:iVersionLastVersionKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	else if (buttonIndex == alertView.cancelButtonIndex)
	{
		//ignore this version
		[[NSUserDefaults standardUserDefaults] setObject:[self mostRecentVersionInDict:remoteVersionsData] forKey:iVersionIgnoreVersionKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	else
	{
		//iphone app store
		NSString *downloadURL = [NSString stringWithFormat:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%i&mt=8", IVERSION_APP_ID];
		
		//take user to app store
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:downloadURL]];
	}
	
}

#else

- (void)localAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	//record this as last viewed release
	[[NSUserDefaults standardUserDefaults] setObject:[self thisVersion] forKey:iVersionLastVersionKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)remoteAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	switch (returnCode)
	{
		case NSAlertAlternateReturn:
		{
			//ignore this version
			[[NSUserDefaults standardUserDefaults] setObject:[self mostRecentVersionInDict:remoteVersionsData] forKey:iVersionIgnoreVersionKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
			break;
		}
		case NSAlertDefaultReturn:
		{
			//go to download page
			NSString *downloadURL = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/app-name/id%i?mt=12&ls=1", IVERSION_APP_ID];
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:downloadURL]];
			break;
		}
	}
}

#endif

#pragma mark -
#pragma mark Public methods

+ (void)appLaunched
{
	[[self sharedInstance] performSelectorInBackground:@selector(checkForNewVersion) withObject:nil];
	[[self sharedInstance] performSelector:@selector(checkIfNewVersion) withObject:nil afterDelay:0.5];
}

+ (void)appEnteredForeground
{
	[[self sharedInstance] performSelectorInBackground:@selector(checkForNewVersion) withObject:nil];
}

@end