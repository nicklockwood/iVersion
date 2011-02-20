//
//  iVersion.h
//  iVersion
//
//  Created by Nick Lockwood on 26/01/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString(iVersion)

- (NSComparisonResult)compareVersion:(NSString *)version;
- (NSComparisonResult)compareVersionDescending:(NSString *)version;

@end


@protocol iVersionDelegate

@optional
- (BOOL)iVersionShouldCheckForNewVersion;
- (void)iVersionDidNotDetectNewVersion;
- (void)iVersionVersionCheckFailed:(NSError *)error;
- (void)iVersionDetectedNewVersion:(NSString *)version details:(NSString *)versionDetails;
- (BOOL)iVersionShouldDisplayNewVersion:(NSString *)version details:(NSString *)versionDetails;

@end


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface iVersion : NSObject<UIAlertViewDelegate>
#else
@interface iVersion : NSObject
#ifdef __i386__
{
	NSDictionary *remoteVersionsDict;
	NSError *downloadError;
	NSUInteger appStoreID;
	NSString *remoteVersionsPlistURL;
	NSString *localVersionsPlistPath;
	NSString *applicationName;
	NSString *applicationVersion;
	BOOL showOnFirstLaunch;
	BOOL groupNotesByVersion;
	float checkPeriod;
	float remindPeriod;
	NSString *newInThisVersionTitle;
	NSString *newVersionAvailableTitle;
	NSString *versionLabelFormat;
	NSString *okButtonLabel;
	NSString *ignoreButtonLabel;
	NSString *remindButtonLabel;
	NSString *downloadButtonLabel;
	BOOL localChecksDisabled;
	BOOL remoteChecksDisabled;
	BOOL localDebug;
	BOOL remoteDebug;
	NSURL * updateURL;
	id<iVersionDelegate> delegate;
}
#endif
#endif

+ (iVersion *)sharedInstance;

//app-specific settings - always set these
@property (nonatomic, assign) NSUInteger appStoreID;
@property (nonatomic, copy) NSString *remoteVersionsPlistURL;
@property (nonatomic, copy) NSString *localVersionsPlistPath;

//application name and version - these are set automatically
@property (nonatomic, copy) NSString *applicationName;
@property (nonatomic, copy) NSString *applicationVersion;

//usage settings - these have sensible defaults
@property (nonatomic, assign) BOOL showOnFirstLaunch;
@property (nonatomic, assign) BOOL groupNotesByVersion;
@property (nonatomic, assign) float checkPeriod;
@property (nonatomic, assign) float remindPeriod;

//message text, you may wish to customise these, e.g. for localisation
@property (nonatomic, copy) NSString *newInThisVersionTitle;
@property (nonatomic, copy) NSString *newVersionAvailableTitle;
@property (nonatomic, copy) NSString *versionLabelFormat;
@property (nonatomic, copy) NSString *okButtonLabel;
@property (nonatomic, copy) NSString *ignoreButtonLabel;
@property (nonatomic, copy) NSString *remindButtonLabel;
@property (nonatomic, copy) NSString *downloadButtonLabel;

//debugging and disabling
@property (nonatomic, assign) BOOL localChecksDisabled;
@property (nonatomic, assign) BOOL remoteChecksDisabled;
@property (nonatomic, assign) BOOL localDebug;
@property (nonatomic, assign) BOOL remoteDebug;

//advanced properties for implementing custom behaviour
@property (nonatomic, copy) NSString *ignoredVersion;
@property (nonatomic, retain) NSDate *lastChecked;
@property (nonatomic, retain) NSDate *lastReminded;
@property (nonatomic, retain) NSURL *updateURL;
@property (nonatomic, assign) id<iVersionDelegate> delegate;

//manually trigger new version check
- (void)checkForNewVersion;

@end
