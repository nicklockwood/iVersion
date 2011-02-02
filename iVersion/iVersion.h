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


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface iVersion : NSObject<UIAlertViewDelegate>
#else
@interface iVersion : NSObject
#endif

+ (iVersion *)sharedInstance;

//app-specific settings - always set these
@property (nonatomic, assign) NSUInteger appStoreID;
@property (nonatomic, retain) NSString *remoteVersionsPlistURL;
@property (nonatomic, retain) NSString *localVersionsPlistPath;

//application name and version - these are set automatically
@property (nonatomic, retain) NSString *applicationName;
@property (nonatomic, retain) NSString *applicationVersion;

//usage settings - these have sensible defaults
@property (nonatomic, assign) BOOL showOnFirstLaunch;
@property (nonatomic, assign) BOOL groupNotesByVersion;
@property (nonatomic, assign) float checkPeriod;
@property (nonatomic, assign) float remindPeriod;

//message text, you may wish to customise these, e.g. for localisation
@property (nonatomic, retain) NSString *newInThisVersionTitle;
@property (nonatomic, retain) NSString *newVersionAvailableTitle;
@property (nonatomic, retain) NSString *versionLabelFormat;
@property (nonatomic, retain) NSString *okButtonLabel;
@property (nonatomic, retain) NSString *ignoreButtonLabel;
@property (nonatomic, retain) NSString *remindButtonLabel;
@property (nonatomic, retain) NSString *downloadButtonLabel;

//debugging and disabling
@property (nonatomic, assign) BOOL localChecksDisabled;
@property (nonatomic, assign) BOOL remoteChecksDisabled;
@property (nonatomic, assign) BOOL localDebug;
@property (nonatomic, assign) BOOL remoteDebug;

@end
