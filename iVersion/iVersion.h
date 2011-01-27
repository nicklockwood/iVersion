//
//  iVersion.h
//  iVersion
//
//  Created by Nick Lockwood on 26/01/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import <Foundation/Foundation.h>


#define IVERSION_APP_ID	355313284
#define IVERSION_REMOTE_VERSIONS_URL @"http://charcoaldesign.co.uk/iVersion/versions.plist"
#define IVERSION_LOCAL_VERSIONS_FILE @"versions.plist"

#define IVERSION_SHOW_ON_FIRST_LAUNCH NO //show release notes the first time app is launched
#define IVERSION_GROUP_NOTES_BY_VERSION YES

#define IVERSION_NEW_IN_THIS_VERSION_TITLE @"New in this version"
#define IVERSION_NEW_VERSION_AVAILABLE_TITLE @"A new version of AppName is available to download"
#define IVERSION_OK_BUTTON @"OK"
#define IVERSION_IGNORE_BUTTON @"Ignore"
#define IVERSION_DOWNLOAD_BUTTON @"Get It"

#define IVERSION_LOCAL_DEBUG YES //always shows local version alert
#define IVERSION_REMOTE_DEBUG YES //always shows remote version alert


@interface NSString(iVersion)

- (NSComparisonResult)compareVersion:(NSString *)version;
- (NSComparisonResult)compareVersionDescending:(NSString *)version;

@end


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface iVersion : NSObject<UIAlertViewDelegate>
#else
@interface iVersion : NSObject
#endif

+ (void)appLaunched;
+ (void)appEnteredForeground;

@end
