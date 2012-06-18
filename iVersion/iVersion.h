//
//  iVersion.h
//
//  Version 1.9.4
//
//  Created by Nick Lockwood on 26/01/2011.
//  Copyright 2011 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from either of these locations:
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

//
//  ARC Helper
//
//  Version 1.3.1
//
//  Created by Nick Lockwood on 05/01/2012.
//  Copyright 2012 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://gist.github.com/1563325
//

#ifndef AH_RETAIN
#if __has_feature(objc_arc)
#define AH_RETAIN(x) (x)
#define AH_RELEASE(x) (void)(x)
#define AH_AUTORELEASE(x) (x)
#define AH_SUPER_DEALLOC (void)(0)
#define __AH_BRIDGE __bridge
#else
#define __AH_WEAK
#define AH_WEAK assign
#define AH_RETAIN(x) [(x) retain]
#define AH_RELEASE(x) [(x) release]
#define AH_AUTORELEASE(x) [(x) autorelease]
#define AH_SUPER_DEALLOC [super dealloc]
#define __AH_BRIDGE
#endif
#endif

//  Weak reference support

#import <Availability.h>
#ifndef AH_WEAK
#if defined __IPHONE_OS_VERSION_MIN_REQUIRED
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
#define __AH_WEAK __weak
#define AH_WEAK weak
#else
#define __AH_WEAK __unsafe_unretained
#define AH_WEAK unsafe_unretained
#endif
#elif defined __MAC_OS_X_VERSION_MIN_REQUIRED
#if __MAC_OS_X_VERSION_MIN_REQUIRED >= 1070
#define __AH_WEAK __weak
#define AH_WEAK weak
#else
#define __AH_WEAK __unsafe_unretained
#define AH_WEAK unsafe_unretained
#endif
#endif
#endif

//  ARC Helper ends


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif


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

@end


@interface iVersion : NSObject

//required for 32-bit Macs
#ifdef __i386__
{
    @private
    
    NSDictionary *_remoteVersionsDict;
    NSError *_downloadError;
    NSUInteger _appStoreID;
    NSString *_remoteVersionsPlistURL;
    NSString *_localVersionsPlistPath;
    NSString *_applicationVersion;
    NSString *_applicationBundleID;
    NSString *_appStoreLanguage;
    NSString *_appStoreCountry;
    BOOL _showOnFirstLaunch;
    BOOL _groupNotesByVersion;
    float _checkPeriod;
    float _remindPeriod;
    NSString *_inThisVersionTitle;
    NSString *_updateAvailableTitle;
    NSString *_versionLabelFormat;
    NSString *_okButtonLabel;
    NSString *_ignoreButtonLabel;
    NSString *_remindButtonLabel;
    NSString *_downloadButtonLabel;
    BOOL _disableAlertViewResizing;
    BOOL _onlyPromptIfMainWindowIsAvailable;
    BOOL _checkAtLaunch;
    BOOL _debug;
    NSURL *_updateURL;
    NSString *_versionDetails;
    id<iVersionDelegate> __AH_WEAK _delegate;
    id _visibleLocalAlert;
    id _visibleRemoteAlert;
    BOOL _currentlyChecking;
}
#endif

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
@property (nonatomic, copy) NSString *appStoreLanguage;
@property (nonatomic, copy) NSString *appStoreCountry;

//usage settings - these have sensible defaults
@property (nonatomic, assign) BOOL showOnFirstLaunch;
@property (nonatomic, assign) BOOL groupNotesByVersion;
@property (nonatomic, assign) float checkPeriod;
@property (nonatomic, assign) float remindPeriod;

//message text - you may wish to customise these, e.g. for localisation
@property (nonatomic, copy) NSString *inThisVersionTitle;
@property (nonatomic, copy) NSString *updateAvailableTitle;
@property (nonatomic, copy) NSString *versionLabelFormat;
@property (nonatomic, copy) NSString *okButtonLabel;
@property (nonatomic, copy) NSString *ignoreButtonLabel;
@property (nonatomic, copy) NSString *remindButtonLabel;
@property (nonatomic, copy) NSString *downloadButtonLabel;

//debugging and automatic checks
@property (nonatomic, assign) BOOL disableAlertViewResizing;
@property (nonatomic, assign) BOOL onlyPromptIfMainWindowIsAvailable;
@property (nonatomic, assign) BOOL checkAtLaunch;
@property (nonatomic, assign) BOOL debug;

//advanced properties for implementing custom behaviour
@property (nonatomic, copy) NSString *ignoredVersion;
@property (nonatomic, strong) NSDate *lastChecked;
@property (nonatomic, strong) NSDate *lastReminded;
@property (nonatomic, strong) NSURL *updateURL;
@property (nonatomic, assign) BOOL viewedVersionDetails;
@property (nonatomic, AH_WEAK) id<iVersionDelegate> delegate;

//manually control behaviour
- (void)openAppPageInAppStore;
- (void)checkIfNewVersion;
- (NSString *)versionDetails;
- (BOOL)shouldCheckForNewVersion;
- (void)checkForNewVersion;

@end
