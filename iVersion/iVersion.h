//
//  iVersion.h
//
//  Version 1.10
//
//  Created by Nick Lockwood on 26/01/2011.
//  Copyright 2011 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
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


#import <Availability.h>
#undef weak_delegate
#undef __weak_delegate
#if __has_feature(objc_arc_weak) && \
(!(defined __MAC_OS_X_VERSION_MIN_REQUIRED) || \
__MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_8)
#define weak_delegate weak
#define __weak_delegate __weak
#else
#define weak_delegate unsafe_unretained
#define __weak_delegate __unsafe_unretained
#endif


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif


extern NSString *const iVersionErrorDomain;


//localisation string keys
static NSString *const iVersionInThisVersionTitleKey = @"iVersionInThisVersionTitle";
static NSString *const iVersionUpdateAvailableTitleKey = @"iVersionUpdateAvailableTitle";
static NSString *const iVersionVersionLabelFormatKey = @"iVersionVersionLabelFormat";
static NSString *const iVersionOKButtonKey = @"iVersionOKButton";
static NSString *const iVersionIgnoreButtonKey = @"iVersionIgnoreButton";
static NSString *const iVersionRemindButtonKey = @"iVersionRemindButton";
static NSString *const iVersionDownloadButtonKey = @"iVersionDownloadButton";


typedef enum
{
    iVersionErrorBundleIdDoesNotMatchAppStore = 1,
    iVersionErrorApplicationNotFoundOnAppStore
}
iVersionErrorCode;


@interface NSString(iVersion)

- (NSComparisonResult)compareVersion:(NSString *)version;
- (NSComparisonResult)compareVersionDescending:(NSString *)version;

@end


@protocol iVersionDelegate <NSObject>
@optional

- (BOOL)iVersionShouldCheckForNewVersion;
- (void)iVersionDidNotDetectNewVersion;
- (void)iVersionVersionCheckDidFailWithError:(NSError *)error;
- (void)iVersionDidDetectNewVersion:(NSString *)version details:(NSString *)versionDetails;
- (BOOL)iVersionShouldDisplayNewVersion:(NSString *)version details:(NSString *)versionDetails;
- (BOOL)iVersionShouldDisplayCurrentVersionDetails:(NSString *)versionDetails;
- (void)iVersionUserDidAttemptToDownloadUpdate:(NSString *)version;
- (void)iVersionUserDidRequestReminderForUpdate:(NSString *)version;
- (void)iVersionUserDidIgnoreUpdate:(NSString *)version;
- (BOOL)iVersionShouldOpenAppStore;

@end


@interface iVersion : NSObject

+ (iVersion *)sharedInstance;

//app store ID - this is only needed if your
//bundle ID is not unique between iOS and Mac app stores
@property (nonatomic, assign) NSUInteger appStoreID;

//app-specific configuration - you may need to set some of these
@property (nonatomic, copy) NSString *remoteVersionsPlistURL;
@property (nonatomic, copy) NSString *localVersionsPlistPath;

//application details - these are set automatically
@property (nonatomic, copy) NSString *applicationVersion;
@property (nonatomic, copy) NSString *applicationBundleID;
@property (nonatomic, copy) NSString *appStoreCountry;

//usage settings - these have sensible defaults
@property (nonatomic, assign) BOOL showOnFirstLaunch;
@property (nonatomic, assign) BOOL groupNotesByVersion;
@property (nonatomic, assign) float checkPeriod;
@property (nonatomic, assign) float remindPeriod;

//message text - you may wish to customise these
@property (nonatomic, copy) NSString *inThisVersionTitle;
@property (nonatomic, copy) NSString *updateAvailableTitle;
@property (nonatomic, copy) NSString *versionLabelFormat;
@property (nonatomic, copy) NSString *okButtonLabel;
@property (nonatomic, copy) NSString *ignoreButtonLabel;
@property (nonatomic, copy) NSString *remindButtonLabel;
@property (nonatomic, copy) NSString *downloadButtonLabel;

//debugging and prompt overrides
@property (nonatomic, assign) BOOL useAllAvailableLanguages;
@property (nonatomic, assign) BOOL disableAlertViewResizing;
@property (nonatomic, assign) BOOL onlyPromptIfMainWindowIsAvailable;
@property (nonatomic, assign) BOOL displayAppUsingStorekitIfAvailable;
@property (nonatomic, assign) BOOL checkAtLaunch;
@property (nonatomic, assign) BOOL verboseLogging;
@property (nonatomic, assign) BOOL previewMode;

//advanced properties for implementing custom behaviour
@property (nonatomic, copy) NSString *ignoredVersion;
@property (nonatomic, strong) NSDate *lastChecked;
@property (nonatomic, strong) NSDate *lastReminded;
@property (nonatomic, strong) NSURL *updateURL;
@property (nonatomic, assign) BOOL viewedVersionDetails;
@property (nonatomic, weak_delegate) id<iVersionDelegate> delegate;

//manually control behaviour
- (void)openAppPageInAppStore;
- (void)checkIfNewVersion;
- (NSString *)versionDetails;
- (BOOL)shouldCheckForNewVersion;
- (void)checkForNewVersion;

@end
