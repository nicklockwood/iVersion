Purpose
--------------

The Mac and iOS App Store update mechanism is somewhat cumbersome and disconnected from the apps themselves. Users often fail to notice when new versions of an app are released, and if they do notice, the App Store's "download all" option means that users often won't see the release notes for the new versions of each of their apps.

Whilst it is not permitted to update an App Store app from within the app itself, there is no reason why an app should not inform the user that the new release is ready, and direct them to the App Store to download the update.

And if your app is not on the App Store, either because it's an in-house/enterprise iOS app, or a Mac app delivered to customers outside of the store, you can't use the App Store update mechanism anyway.

iVersion is a simple, *zero-config* class to allow iPhone and Mac App Store apps to automatically check for updates and inform the user about new features.

iVersion automatically detects when the new version of an app is released on the App Store and informs the user with a helpful alert that links them directly to the app download page.

Or if your app is not on the store, iVersion lets you specify a remote plist file to check for new releases, and a download URL where users can get the latest release.

iVersion has an additional function, which is to tell users about important new features when they first run an app after downloading a new version.

![Screenshot IOS](http://github.com/Daij-Djan/iVersion/raw/master/screen_ios.png)
![Screenshot OSX](http://github.com/Daij-Djan/iVersion/raw/master/screen_osx.png)

Supported OS & SDK Versions
-----------------------------

* Supported build target - iOS 6.0 / Mac OS 10.8 (Xcode 4.5, Apple LLVM compiler 4.1)
* Earliest supported deployment target - iOS 5.0 / Mac OS 10.7
* Earliest compatible deployment target - iOS 4.3 / Mac OS 10.6

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this OS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.


ARC Compatibility
------------------

As of version 1.10, iVersion requires ARC. If you wish to use iVersion in a non-ARC project, just add the -fobjc-arc compiler flag to the iVersion.m class. To do this, go to the Build Phases tab in your target settings, open the Compile Sources group, double-click iVersion.m in the list and type -fobjc-arc into the popover.

If you wish to convert your whole project to ARC, comment out the #error line in iVersion.m, then run the Edit > Refactor > Convert to Objective-C ARC... tool in Xcode and make sure all files that you wish to use ARC for (including iVersion.m) are checked.


Thread Safety
--------------

iVersion uses threading internally to avoid blocking the UI, but none of the iVersion external interfaces are thread safe and you should not call any methods or set any properties on iVersion except from the main thread.


Installation
--------------

To install iVersion into your app, drag the iVersion.h, .m and .bundle files into your project. You can omit the .bundle if you are not interested in localised copy. On iOS you will also need to add the StoreKit framework.

**Alternatively** (**I prefer this** as it keeps sources more separate) you can include the iVersion.xcodeproj in your project (drag it there) and link against the library. Then...<br/>
…On OSX: Link against the iVersion.framework and add it to your app via a copy phase.<br/> 
...On IOS: Link against the libiVersion.a and drag the .bundle file to your copy resources build phase

iVersion typically requires no configuration at all and will simply run automatically, using the Application's bundle ID to look it up on the App Store.

**Note:** If you have apps with matching bundle IDs on both the Mac and iOS App Stores (even if they use different capitalisation), the lookup mechanism won't work, so you'll need to set the appStoreID property, which is a numeric ID that can be found in iTunes Connect after you set up an app. This is only applicable to App Store apps.

Alternatively (or additionally) you can specify an optional remotely hosted Plist file that will be used for the release notes instead of the ones on iTunes. Even if your app is on the store, there are a few advantages to providing your own release notes plist:

1. You can provide release notes for multiple versions, and if users skip a version they will see the release notes for all the updates they've missed.

2. You can provide more concise release notes, suitable for display on the iPhone screen. 

3. You can delay the iVersion update alert until you are ready by not including an entry for the latest release until after the app has gone live.

If you do wish to customise iVersion, the best time to do this is *before* the app has finished launching. The easiest way to do this is to add the iVersion configuration code in your AppDelegate's `initialize` method, like this:

	+ (void)initialize
	{
		//example configuration
		[iVersion sharedInstance].appStoreID = 355313284;
		[iVersion sharedInstance].remoteVersionsPlistURL = @"http://example.com/versions.plist";
	}

The Plist file you specify will need to be hosted on a public-facing web server somewhere. You can optionally also add a Plist file to your app containing the release notes for the current version, and specify its path using the `localVersionsPlistPath` property.

The format for both of these plists is as follows:

	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
		<key>1.0</key>
		<string>First release</string>
		<key>1.1</key>
		<string>NEW: Added  new snoodlebar feature
	FIX: Fixed the bugalloo glitch</string>
		...
	</dict>
	</plist>

The root node of the plist is a dictionary containing one or more items. Each item represents a particular version of your application.

The key for each value must be a numerical version number consisting of one or more positive integers separated by decimal points. These should match the values you set for the applicationVersion property of iVersion, which by default is set to the Bundle Version (CFBundleShortVersionString or CFBundleVersion) key in your application's info.plist.

Each value should be either a multi-line string or an array of strings, each representing a single bullet point in your release notes. There is no restriction to the format of each release note - the approach in the example above is just a suggestion. You can also omit the release notes if you want and just have an empty <array/>.


Plist Tips
--------------

It is not recommended that you include every single version of your app in the release notes. In practice, if a user updates so infrequently that they miss three or more consecutive versions, you still probably only want to show them the last couple of releases worth of notes, so delete older releases from the file when you update.

Do not feel that the release notes have to exactly mirror those in iTunes or the Mac App Store. There is limited space in a modal alert and users won't want to read a lot of text whenever they launch your app, so it's probably best just to list the key new features in your versions plist.

The local and remote release notes plists do not have to match. Whilst it may be convenient to make them identical from a maintenance point of view, the local version works better if it is written in a slightly different tone. For example the remote release notes might read:

    Version 1.1
	
	- Fixed crashing bug
	- Added shiny new menu graphics
	- New sound settings

Whereas the local one might say:

	Check out the new sound options in the settings panel. You can access the settings from the home screen

There's no point in mentioning the bug fix or new graphics because the user can see this easily enough just by using the app. On the other hand, they might not notice the new sound options, or know how to find them.

Also don't always feel you have to include the local release notes file. If there are no features that need drawing attention to in the new release, just omit the file - it won't prevent you adding the remote versions file to prompt users to upgrade, and it won't prevent local release notes in future releases from working correctly.


Configuration
--------------

To configure iVersion, there are a number of properties of the iVersion class that can alter the behaviour and appearance of iVersion. These should be mostly self- explanatory, but they are documented below:

	@property (nonatomic, assign) NSUInteger appStoreID;

This should match the iTunes app ID of your application, which you can get from iTunes connect after setting up your app. This value is not normally necessary and is generally only required if you have the aforementioned conflict between bundle IDs for your Mac and iOS apps. This feature is also only used for remote version updates, so you can ignore this if you do not intend to use that feature.

	@property (nonatomic, copy) NSString *remoteVersionsPlistURL;

This is the URL of the remotely hosted plist that iVersion will check for release notes. As of iVersion 1.8, you can safely update this file *before* your new release has been approved by Apple and appeared in the store, although be cautious if there are existing versions of your app pointing at the file that use older versions of the iVersion library. For testing purposes, you may wish to create a separate copy of the file at a different address and use a build constant to switch which version the app points at. Set this value to nil if you want to just use the release notes on iTunes. Do not set it to an invalid URL such as example.com because this will waste battery, CPU and bandwidth as the app tries to check the invalid URL each time it launches.

	@property (nonatomic, copy) NSString *localVersionsPlistPath;

The file name of your local release notes plist used to tell users about new features when they first launch a new update. Set this value to nil if you do not want your app to display release notes for the current version.

	@property (nonatomic, copy) NSString *applicationVersion;

The current version number of the app. This is set automatically from the  CFBundleShortVersionString (if available) or CFBundleVersion string in the info.plist and it's probably not a good idea to change it unless you know what you are doing. Note that the version numbers on iTunes and in the remote versions Plist will be compared to this value, not the one in the info.plist.

    @property (nonatomic, copy) NSString *applicationBundleID;

This is the application bundle ID, used to retrieve the latest version and release notes from iTunes. This is set automatically from the app's info.plist, so you shouldn't need to change it except for testing purposes.

    @property (nonatomic, copy) NSString *appStoreCountry;

This is the two-letter country code used to specify which iTunes store to check. It is set automatically from the device locale preferences, so shouldn't need to be changed in most cases. You can override this to point to the US store, or another specific store if you prefer, which may be a good idea if your app is only available in certain countries, however be warned that this will affect the language used to display the release notes.

	@property (nonatomic, assign) BOOL showOnFirstLaunch;

Specify whether the release notes for the current version should be shown the first time the user launches the app. If set to no it means that users who, for example, download version 1.1 of your app but never installed a previous version, won't be shown the new features in version 1.1.

	@property (nonatomic, assign) BOOL groupNotesByVersion;

If your release notes files contains multiple versions, this option will group the release notes by their version number in the alert shown to the user. If set to NO, the release notes will be shown as a single list. Defaults to NO.

	@property (nonatomic, assign) float checkPeriod;

Sets how frequently the app will check for new releases. This is measured in days but can be set to a fractional value, e.g. 0.5 for half a day. Set this to a higher value to avoid excessive traffic to your server. A value of zero means the app will check every time it's launched. As of iVersion 1.8, the default value is zero.

	@property (nonatomic, assign) float remindPeriod;

How long the app should wait before reminding a user of a new version after they select the "remind me later" option. A value of zero means the app will remind the user every launch. Note that this value supersedes the check period, so once a reminder is set, the app won't check for new releases during the reminder period, even if new version are released in the meantime. The default remind period is one day.

	@property (nonatomic, copy) NSString *inThisVersionTitle;

The title displayed for features in the current version (i.e. features in the local version s plist file).

	@property (nonatomic, copy) NSString *updateAvailableTitle;

The title displayed when iVersion detects a new version of the app has appeared in the remote versions plist. The latest version number will automatically be appended to this title in brackets if `groupNotesByVersion` is set to NO.

	@property (nonatomic, copy) NSString *versionLabelFormat;

The format string for the release notes version separators. This should include a %@ placeholder for the version number, e.g "Version %@". This label is not used unless `groupNotesByVersion` is set to YES.

	@property (nonatomic, copy) NSString *okButtonLabel;
	
The button label for the button to dismiss the "new in this version" modal.

	@property (nonatomic, copy) NSString *ignoreButtonLabel;

The button label for the button the user presses if they do not want to download a new update.

	@property (nonatomic, copy) NSString *remindButtonLabel;

The button label for the button the user presses if they don't want to download a new update immediately, but do want to be reminded about it in future. Set this to `@""` if you don't want to display the remind me button - e.g. if you don't have space on screen.

	@property (nonatomic, copy) NSString *downloadButtonLabel;

The button label for the button the user presses if they want to download a new update.

    @property (nonatomic, assign) BOOL useAllAvailableLanguages;

By default, iVersion will use all available languages in the iVersion.bundle, even if used in an app that does not support localisation. If you would prefer to restrict iVersion to only use the same set of languages that your application already supports, set this property to NO. (Defaults to YES).

    @property (nonatomic, assign) BOOL disableAlertViewResizing;

On iPhone, iVersion includes some logic to resize the alert view to ensure that your release notes message doesn't become truncated in landscape mode. The code to do this is a rather nasty hack, so if your alert text is very short and/or your app only needs to function in portrait mode on iPhone, you may wish to set this property to YES, which may help make your app more robust against future iOS updates. Try the *Resizing Disabled* example for a demonstration of the effect.

    @property (nonatomic, assign) BOOL onlyPromptIfMainWindowIsAvailable;

This setting is applicable to Mac OS only. By default, on Mac OS the iVersion alert is displayed as sheet on the main window. Some applications do not have a main window, so this approach doesn't work. For such applications, set this property to NO to allow the iVersion alert to be displayed as a regular modal window.

    @property (nonatomic, assign) BOOL displayAppUsingStorekitIfAvailable;

By default, if iVersion is running on iOS 6 or above then when the user presses Dwonload, the app page will be displayed directly within the app instead of linking to the App Store app. If you don't want that, set this property to NO.

	@property (nonatomic, assign) BOOL checkAtLaunch;

Set this to NO to disable checking for local and remote release notes automatically when the app is launched or returns from the background. Disabling this option does not prevent you from manually triggering the checks by calling `checkIfNewVersion` and `checkForNewVersion` respectively.

    @property (nonatomic, assign) BOOL verboseLogging;

This option will cause iVersion to send detailed logs to the console about the version checking process. If your app is not correctly detecting a new release, this will help you figure out why. Verbose logging is enabled by default on debug builds, and disabled on release and deployment builds.

	@property (nonatomic, assign) BOOL previewMode;

If set to YES, iVersion will always display the contents of the local and remote versions plists, irrespective of the version number of the current build. Use this to proofread your release notes during testing, but disable it for the final release.


Advanced properties
---------------

If the default iVersion behaviour doesn't meet your requirements, you can implement your own by using the advanced properties, methods and delegate. The properties below let you access internal state and override it:

	@property (nonatomic, strong) NSURL *updateURL;

The URL that the app will direct the user to if an update is detected and they choose to download it. You will need to override this for in-house apps or apps that are not distributed via the App Store. If you are implementing your own download button for a regular app-store-app, you should use the openAppPageInAppStore method instead of opening this URL, especially on Mac OS, as the process for opening the Mac App Store is more complex than merely opening the URL.

	@property (nonatomic, copy) NSString *ignoredVersion;

The version string of the last app version that the user ignored. If the user hasn't ignored any releases, this will be nil. Set this to nil to clear the ignored version.

	@property (nonatomic, strong) NSDate *lastChecked;

The last date on which iVersion checked for an update. You can use this in combination with the checkPeriod to determine if the app should check again.

	@property (nonatomic, strong) NSDate *lastReminded;

The last date on which the user was reminded of a new version. You can use this in combination with the remindPeriod to determine if the app should check again. Set this to nil to clear the reminder delay.

	@property (nonatomic, assign) BOOL viewedVersionDetails;

Flag that indicates if the local version details have been viewed (YES) or not (NO).

	@property (nonatomic, assign) id<iVersionDelegate> delegate;

An object you have supplied that implements the iVersionDelegate protocol, documented below. Use this to detect and/or override iVersion's default behaviour. This defaults to the App Delegate, so if you are using your App Delegate as your iVersion delegate, you don't need to set this property.


Advanced methods
---------------

	- (void)openAppPageInAppStore;

This method will open the application page in the Mac or iPhone App Store, or directly within the app, depending on which platform and OS version is running. You should use this method instead of the updateURL property, as the process for launching the app store is more complex than merely opening the URL in many cases. Note that this method depends on the `appStoreID` which is only retrieved after polling the iTunes server, so if you intend to call this method without first doing an update check, you will need to set the `appStoreID` property yourself beforehand.

	- (void)checkIfNewVersion;

This method will check the local versions Plist to see if there are new notes to be displayed, and will display them in an alert. This method is called automatically on launch if `checkAtLaunch` is set to YES.

	- (NSString *)versionDetails;

This returns the local release notes for the current version, or any versions that have been released since the last time the app was launched, depending on how many versions are included in the local version plist file. If this isn't the first time this version of the app was launched, only the most recent version is included.
	
	- (BOOL)shouldCheckForNewVersion;
	
This method checks to see if the criteria for checking for a new version have been met. You can use this to decide whether to check for version updates if you have disabled the automatic display at app launch.
	
	- (void)checkForNewVersion;

This method will trigger a new check for new versions, ignoring the checkPeriod and remindPeriod properties. This method is called automatically on launch and when the app returns from background if `checkAtLaunch` is set to YES and `shouldCheckForNewVersion` returns YES.


Delegate methods
---------------

The iVersionDelegate protocol provides the following methods that can be used to intercept iVersion events and override the default behaviour. All methods are optional.

	- (BOOL)iVersionShouldCheckForNewVersion;

This is called if the checking criteria have all been met and iVersion is about to check for a new version. If you return NO, the check will not be performed. This method is not called if you trigger the check manually with the checkForNewVersion method.

	- (void)iVersionDidNotDetectNewVersion;

This is called if the version check did not detect any new versions of the application.

	- (void)iVersionVersionCheckDidFailWithError:(NSError *)error;

This is called if the version check failed due to network issues or because the remote versions Plist file was missing or corrupt.

	- (void)iVersionDidDetectNewVersion:(NSString *)version details:(NSString *)versionDetails;

This is called if a new version was detected.

	- (BOOL)iVersionShouldDisplayNewVersion:(NSString *)version details:(NSString *)versionDetails;

This is called immediately before the new (remote) version details alert is displayed. Return NO to prevent the alert from being displayed. Note that if you are implementing the alert yourself you will also need to set the `lastChecked`, `lastReminded` and `ignoredVersion` properties yourself, depending on the user response.

	- (BOOL)iVersionShouldDisplayCurrentVersionDetails:(NSString *)versionDetails;

This is called immediately before the current (local) version details alert is displayed. Return NO to prevent the alert from being displayed. Note that if you intend to implement this notification yourself, you will need to set the viewedVersionDetails flag manually.

	- (void)iVersionUserDidAttemptToDownloadUpdate:(NSString *)version;
	
This is called when the user pressed the download button in the new version alert. This is useful if you want to log user interaction with iVersion. This method is only called if you are using the standard iVersion alert view and will not be called automatically if you provide a custom alert implementation or call the `openAppPageInAppStore` method directly.
	
	- (void)iVersionUserDidRequestReminderForUpdate:(NSString *)version;
	
This is called when the user asks to be reminded about a new version. This is useful if you want to log user interaction with iVersion. This method is only called if you are using the standard iVersion alert view and will not be called automatically if you provide a custom alert implementation.
	
	- (void)iVersionUserDidIgnoreUpdate:(NSString *)version;
	
This is called when the user presses the ignore in the new version alert. This is useful if you want to log user interaction with iVersion. This method is only called if you are using the standard iVersion alert view and will not be called automatically if you provide a custom alert implementation.

    - (BOOL)iVersionShouldopenAppStore;
    
This method is called immediately before iVersion attempts to open the app store, either via a URL or using the StoreKit in-app product view controller. Return NO if you wish to implement your own update page logic.
	

Localisation
---------------

The defaults strings for iVersion are already localised for many languages. By default, iVersion will use all the localisations in the iVersion.bundle even in an app that is not localised, or which is only localised to a subset of the languages that iVersion supports.

If you would prefer iVersion to only use the localisations that are enabled in your application (so that if your app only supports English, French and Spanish, iVersion will automatically be localised for those languages, but not for German, even though iVersion includes a German language file), set the `useAllAvailableLanguages` option to NO.

iVersion will automatically use the localised release notes that you've specified on iTunes, if available.

It is not recommended that you modify the strings files in the iVersion.bundle, as it will complicate updating to newer versions of iVersion. The exception to this is if you would like to submit additional languages or improvements or corrections to the localisations in the iVersion project on github (which are greatly appreciated).

If you want to add an additional language for iVersion in your app without submitting them back to the github project, you can add these strings directly to the appropriate Localizable.strings file in your project folder. If you wish to replace some or all of the default iVersion strings, the simplest option is to copy just those strings into your own Localizable.strings file and then modify them. iVersion will automatically use strings in the main application bundle in preference to the ones in the iVersion bundle so you can override any string in this way.

If you do not want to use *any* of the default localisations, you can omit the iVersion.bundle altogether. Note that if you only want to support a subset of languages that iVersion supports, it is not neccesary to delete the other strings files from iVersion.bundle - just set `useAllAvailableLanguages` to NO, and iVersion will only use the languages that your app already supports.

The old method of overriding iVersion's default strings by using individual setter methods (see below) is still supported, however the recommended approach is now to add those strings to your project's Localizable.strings file, which will be detected automatically by iVersion.

	+ (void)initialize
	{
		[iVersion sharedInstance].inThisVersionTitle = NSLocalizedString(@"New in this version", @"iVersion local version alert title");
		[iVersion sharedInstance].updateAvailableTitle = NSLocalizedString(@"A new version of MyApp is available to download", @"iVersion new version alert title");
		[iVersion sharedInstance].versionLabelFormat = NSLocalizedString(@"Version %@", @"iVersion version label format");
		[iVersion sharedInstance].okButtonLabel = NSLocalizedString(@"OK", @"iVersion OK button");
		[iVersion sharedInstance].ignoreButtonLabel = NSLocalizedString(@"Ignore", @"iVersion ignore button");
		[iVersion sharedInstance].remindButtonLabel = NSLocalizedString(@"Remind Me Later", @"iVersion remind button");
		[iVersion sharedInstance].downloadButtonLabel = NSLocalizedString(@"Download", @"iVersion download button");
	}

If you are using the remote versions Plist, and you need to provide localised release notes, the simplest way to do this is to localise the `remoteVersionsPlistURL` file and provide a different URL for each language, like this:
    
    + (void)initialize
	{
        [iVersion sharedInstance].remoteVersionsPlistURL = NSLocalizedString(@"http://example.com/versions_en.plist", @"remote iVersion plist URL");
    }

Example Projects
---------------

When you build and run the basic Mac or iPhone example project for the first time, it will show an alert saying that a new version is available. This is because it has downloaded the remote versions.plist file and determined that the latest version is newer than the currently running app.

Quit the app, go into the iVersion-Info.plist file and edit the bundle version to 1.2. Now rebuild the app.

This time it will not say that a new version is available. In effect, you have simulated an upgrade. Instead it will tell you about the new features in your currently installed version. This is because it has found that the bundle version of the current app is newer than the last recorded version that was launched, and has checked the local versions.plist file for a release notes entry for the new version.

If you dismiss the dialog and then quit and relaunch the app you should now see nothing. This is because the app has detected that the bundle version hasn't changed since you last launched the app.

To show the alerts again, delete the app from the simulator and reset the bundle version to 1.1. Alternatively, enable the `previewMode` option to force the alerts to appear on launch.


Advanced Example
---------------

The advanced example demonstrates how you might implement a completely bespoke iVersion interface. Automatic version checking is disabled and instead the user can trigger a check by pressing the "Check for new version" button.

When pressed, the app display a progress wheel and then prints the result in a console underneath the button.

The example is for Mac OS, but the same thing can be applied on iOS.