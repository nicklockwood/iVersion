Purpose
--------------

The App Store app updates notification system is somewhat cumbersome and disconnected from the apps themselves. Users often fail to notice when new versions of the app are released, and if they do notice, the App Store's 'download all' mechanism means that users often won't see the release notes for the new version.

Whilst it is not possible to bypass the App Store and update an app from within the app itself as this violates the App Store terms and conditions, there is no reason why an app should not inform the user that the new release is ready, and direct them to the correct page in the App Store.

iVersion is a simple, drop-in class to allow iPhone and Mac App Store apps to automatically check for updates and inform the user about new features.

iVersion has an additional function, which is to tell users about important new features when they first run an app after downloading a new version.

NOTE: iVersion cannot tell if a given release is available to download, so make sure that you only update the remote version file after apple has approved your app and it has appeared in the store. In principle you could create a web service that scrapes the iTunes latest releases RSS feed and generates the remote version plist file for your app automatically, but this is outside the scope of this project currently.


Installation
--------------

To install iVersion into your app, drag the iVersion.h and .m files into your project.

To enable iVersion in your application, add a call to [iVersion appLaunched] to your app delegate's applicationDidFinishLaunching method, and (on the iPhone only) add a call to [iVersion appEnteredForeground] to the applicationWillEnterForeground method. The resultant code will look something like this:

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
    [self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];
	
	//iVersion init
	[iVersion appLaunched];

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	//iVersion init
	[iVersion appEnteredForeground];
}

You will also need to add a plist file to your app containing the release notes for the current version, and host another copy on a web-facing server somewhere. The format for these plists is as follows:

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>1.0</key>
	<array>
		<string>First release</string>
	</array>
	<key>1.1</key>
	<array>
		<string>NEW: Added  new snoodlebar feature</string>
		<string>FIX: Fixed the bugalloo glitch</string>
	</array>
	...
</dict>
</plist>

The root node of the plist is a dictionary containing one or more items. Each item represents a particular version of your application.

The key for each value must be a numerical version number consisting of one or more positive integers separated by decimal points. These should match the values you set for the Bundle Version (CFBundleVersion) key in your application's info.plist.

Each value should be an array of one or more strings, each representing a single bullet point in your release notes. There is no restriction to the format of each release note - the approach in the example above is just a suggestion. You may prefer to put all your notes into a single string and add your own line formatting or indenting.


Plist Tips
--------------

It is not recommended that you include every single version of your app in the release notes. In practice, if a user updates so infrequently that they miss three or more consecutive versions, you still probably only want to show them the last couple of releases worth of notes, so delete older releases from the file when you update.

Do not feel that the release notes have to exactly mirror those in iTunes or the Mac App Store. There is limited space in a modal alert and users won't want to read a lot of text whenever they launch your app, so it's probably best just to list the key new features in your versions plist.

The local and remote release notes plists do not have to match. Whilst it may be convenient to make them identical from a maintenance point of view, the local version works better if it is written in a slightly different tone. For example the remote release notes might read:

"
Version 1.1

- Fixed crashing bug
- Added shiny new menu graphics
- New sound settings
"

Whereas the local one might say:

"
Check out the new sound options in the settings panel. You can access the settings from the home screen
"

There's no point in mentioning the bug fix or new graphics because the user can see this easily enough just by using the app. On the other hand, they might not notice the new sound options, or know how to find them.

Also don't always feel you have to include the local release notes file. If there are no features that need drawing attention to in the new release, just omit the file - it won't prevent you adding the remote file to prompt users to upgrade, and it won't prevent local release notes in future releases from working correctly.


Configuration
--------------

To configure iVersion, there are a number of constants in the iVersion.h file
that can alter the behaviour and appearance. These should be mostly self-
explanatory, but key ones are documented below:

IVERSION_APP_ID - this should match the iTunes app ID of your application, which you can get from iTunes connect after setting up your app. This is only used for remote version updates, so you can ignore this if you do not intend to use that feature (although it should still be set to a valid integer value).

IVERSION_REMOTE_VERSIONS_URL - This is the URL of the remotely hosted plist that iVersion will check for new releases. As noted above, make sure you only update this file after your new release has been approved by Apple and appeared in the store or you will have some very confused customers. For testing purposes, you may wish to create a separate copy of the file at a different address and use a build constant to switch which version the app points at. Set this value to nil if you do not want your app to check for updates automatically. Do not set it to an invalid URL such as example.com because this will waste battery, CPU and bandwidth as the app tries to check the invalid URL each time it launches.

IVERSION_LOCAL_VERSIONS_FILE - The file name of your local release notes plist used to tell users about new features when they first launch a new update. Set this value to nil if you do not want your app to display release notes for the current version.

IVERSION_SHOW_ON_FIRST_LAUNCH - Specify whether the release notes for the current version should be shown the first time the user launches the app. If set to no it means that users who, for example, download version 1.1 of your app but never installed a previous version, won't be shown the new features in version 1.1.

IVERSION_GROUP_NOTES_BY_VERSION - If your release notes files contains multiple versions, this option will group the release notes by their version number in the alert shown to the user. If set to NO, the release notes will be shown as a single list.

IVERSION_NEW_IN_THIS_VERSION_TITLE - The title displayed for features in the current version (i.e. feature sin the local version plist file).

IVERSION_NEW_VERSION_AVAILABLE_TITLE - The title displayed when iVersion detects a new version of the app is available for download.

IVERSION_OK_BUTTON - The dismissal button label for the "new in this version" modal alert.

IVERSION_IGNORE_BUTTON - The button label for the button the user presses if they do not want to download a new update.

IVERSION_DOWNLOAD_BUTTON - The button label for the button the user presses if they want to download a new update.

IVERSION_LOCAL_DEBUG - If set to YES, iVersion will always display the contents of the local versions plist, irrespective of the version number of the current build. Use this to proofread your release notes during testing, but disable it for the final release.

IVERSION_REMOTE_DEBUG - If set to YES, iVersion will always display the contents of the remote versions plist, irrespective of the version number of the current build. Use this to proofread your release notes during testing, but disable it for the final release.


Example Project
---------------

When you build and run the example project for the first time, it will show an alert saying that a new version is available. This is because it has downloaded the remote versions.plist file and determined that the latest version is newer than the currently running app.

Quit the app, go into the iVersion-Info.plist file and edit the bundle version to 1.2. Now rebuild the app.

This time it will not say that a new version is available. In effect you have simulated an upgrade. Instead it will tell you about the new features in your currently installed version. This is because it has found that the bundle version of the current app is newer than the last recorded version that was launched, and has checked the local versions.plist file for a release notes entry for the new version.

If you dismiss the dialog and then quit and relaunch the app you should now see nothing. This is because the app has detected that the bundle version hasn't changed since you last launched the app.

To show the alerts again, delete the app from the simulator and reset the bundle  version to 1.1. Alternatively, enabled the debug settings to force the alerts to appear on launch.