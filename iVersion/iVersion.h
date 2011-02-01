//
//  iVersion.h
//  iVersion
//
//  Created by Nick Lockwood on 26/01/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import <Foundation/Foundation.h>


#define IVERSION_APP_STORE_ID 355313284
#define IVERSION_APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey]
#define IVERSION_REMOTE_VERSIONS_URL @"http://charcoaldesign.co.uk/iVersion/versions.plist"
#define IVERSION_LOCAL_VERSIONS_FILE @"versions.plist"

#define IVERSION_SHOW_ON_FIRST_LAUNCH NO //show release notes the first time app is launched
#define IVERSION_GROUP_NOTES_BY_VERSION YES
#define IVERSION_CHECK_PERIOD 0.5 //measured in days
#define IVERSION_REMIND_PERIOD 1 //measured in days

#define IVERSION_NEW_IN_THIS_VERSION_TITLE @"New in this version"
#define IVERSION_NEW_VERSION_AVAILABLE_TITLE [NSString stringWithFormat:@"A new version of %@ is available to download", IVERSION_APP_NAME]
#define IVERSION_OK_BUTTON @"OK"
#define IVERSION_IGNORE_BUTTON @"Ignore"
#define IVERSION_REMIND_BUTTON @"Remind Me Later"
#define IVERSION_DOWNLOAD_BUTTON @"Get It"

#define IVERSION_LOCAL_DEBUG NO //always shows local version alert
#define IVERSION_REMOTE_DEBUG NO //always shows remote version alert


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
