//
//  iVersion.h
//
//  Version 1.6.3
//
//  Created by Nick Lockwood on 26/01/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//
//  Get the latest version of iCarousel from either of these locations:
//
//  http://charcoaldesign.co.uk/source/cocoa#iversion
//  https://github.com/nicklockwood/iVersion
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
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
- (BOOL)iVersionShouldDisplayCurrentVersionDetails:(NSString *)versionDetails;

@end


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
	NSString *inThisVersionTitle;
	NSString *updateAvailableTitle;
	NSString *versionLabelFormat;
	NSString *okButtonLabel;
	NSString *ignoreButtonLabel;
	NSString *remindButtonLabel;
	NSString *downloadButtonLabel;
	BOOL localChecksDisabled;
	BOOL remoteChecksDisabled;
	BOOL localDebug;
	BOOL remoteDebug;
	NSURL *updateURL;
	NSString *versionDetails;
	id<iVersionDelegate> delegate;
}
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
@property (nonatomic, copy) NSString *inThisVersionTitle;
@property (nonatomic, copy) NSString *updateAvailableTitle;
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
@property (nonatomic, assign) BOOL viewedVersionDetails;
@property (nonatomic, assign) id<iVersionDelegate> delegate;

//manually control behaviour
- (void)openAppPageInAppStore;
- (void)checkForNewVersion;
- (NSString *)versionDetails;

@end
