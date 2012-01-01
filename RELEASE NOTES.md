Version 1.7.1

- Now uses CFBundleShortVersionString when available instead of CFBundleVersion for the application version
- Fixed bug in iversion.php web service where platform was not set correctly
- Added logic to web service to use curl when available instead of file_get_contents for reading in iTunes search service data

Version 1.7

- Added additional delegate methods to facilitate logging
- Renamed some delegate methods
- Removed localChecksDisabled property and renamed remoteChecksDisabled property to checkAtLaunch for clarity and consistency with the iRate and iNotify libraries
- Combined remoteDebug and localDebug to simplify usage
- Added checkIfNewVersion method to manually trigger display of local version details

Version 1.6.4

- Updated iVersion web service to use official iTunes App Store search APIs
- iVersion now uses CFBundleDisplayName for the application name (if available) 
- Increased Mac app store refresh delay for older Macs
- Simplified version comparison logic
- Reorganised examples

Version 1.6.3

- Fixed web service and updated project for Xcode 4.2

Version 1.6.2

- Fixed version details in new version alert on iOS

Version 1.6.1

- Fixed crash on iOS versions before 4.0 when downloading version details.

Version 1.6

- Added openAppPageInAppStore method for more reliably opening Mac App Store
- Fixed issue with local versions plist path on Mac OS
- Renamed a couple of configuration settings names to comply with Cocoa conventions and prevent static analyzer warnings
- Added explicit ivars to support i386 (32bit x86) targets

Version 1.5

- Added PHP web service example for automatically scraping version from iTunes
- Added delegate and additional accessor properties for custom behaviour
- Added advanced example project to demonstrate use of the delegate protocol

Version 1.4

- Now compatible with iOS 3.x
- Local versions plist path can now be nested within a subfolder of Resources

Version 1.3

- Added Mac demo project
- Changed Mac App Store opening mechanism to no longer launch browser first
- Corrected error in documentation

Version 1.2

- Configuration no longer involves modifying iVersion.h file
- Now detects application launch and app switching events automatically
- No longer requires release notes to be included in update notifications
- Simpler to localise

Version 1.1

- Added optional remind me button
- Added ability to specify update period
- Local versions file path can now be set to nil

Version 1.0

- Initial release