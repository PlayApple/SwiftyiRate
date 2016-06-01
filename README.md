#SwiftyiRate [中文说明](http://blog.csdn.net/cocos2der/article/details/51555127)
--------------

SwiftyiRate makes it easy to deal with rate app in Swift.

1. [Requirements](#requirements)
1. [Integration](#integration)
1. [Usage](#usage)
	- [Initialization](#initialization)
1. [Configuration](#Configuration)
1. [Advanced properties](#Advanced properties)
1. [Methods](#Methods)
1. [Delegate methods](#Delegate methods)
1. [Localisation](#Localisation)
1. [Example Projects](#Example Projects)
1. [Advanced Example](#Advanced Example)
1. [Release Notes](#Release Notes)

## Requirements
--------------

- iOS 7.0+
- Xcode 7

## Integration
--------------
####CocoaPods (iOS 8+)
You can use [Cocoapods](http://cocoapods.org/) to install `SwiftyiRate`by adding it to your `Podfile`:
```ruby
platform :ios, '8.0'
use_frameworks!

target 'MyApp' do
	pod 'SwiftyiRate', :git => 'https://github.com/PlayApple/SwiftyiRate.git'
end
```

## Usage
--------------
####Initialization

Add code in AppDelegate.swift
```swift
import SwiftyiRate
```

```swift
override class func initialize () {
	// overriding the default SwiftyiRate strings
	SwiftyiRate.sharedSwiftyiRate.messageTitle = NSLocalizedString("kMessageTitle", comment: "iRate message title")
	SwiftyiRate.sharedSwiftyiRate.message = NSLocalizedString("kMessage", comment: "iRate message")
	SwiftyiRate.sharedSwiftyiRate.cancelButtonLabel = NSLocalizedString("kCancelButtonLabel", comment: "Decline Button")
	SwiftyiRate.sharedSwiftyiRate.remindButtonLabel = NSLocalizedString("kRemindButtonLabel", comment: "Remind Button")
	SwiftyiRate.sharedSwiftyiRate.rateButtonLabel = NSLocalizedString("kRateButtonLabel", comment: "Rate Button")
}
```

## Configuration
--------------
To configure SwiftyiRate, there are a number of properties of the SwiftyiRate class that can alter the behaviour and appearance of SwiftyiRate. These should be mostly self- explanatory, but they are documented below:

```swift
var appStoreID: Int?
```
This should match the iTunes app ID of your application, which you can get from iTunes connect after setting up your app. This value is not normally necessary and is generally only required if you have the aforementioned conflict between bundle IDs for your Mac and iOS apps, or in the case of Sandboxed Mac apps, if your app does not have network permission because it won't be able to fetch the appStoreID automatically using iTunes services.

```swift
var appStoreGenreID: Int?
```
This is the type of app, used to determine the default text for the rating dialog. This is set automatically by calling an iTunes service, so you shouldn't need to set it manually for most purposes. If you do wish to override this value, setting it to the `iRateAppStoreGameGenreID` constant will cause SwiftyiRate to use the "game" version of the rating dialog, and setting it to any other value will use the "app" version of the rating dialog.

```swift
var appStoreCountry: Int?
```
This is the two-letter country code used to specify which iTunes store to check. It is set automatically from the device locale preferences, so shouldn't need to be changed in most cases. You can override this to point to the US store, or another specific store if you prefer, which may be a good idea if your app is only available in certain countries.

```swift
var applicationName: String
```
This is the name of the app displayed in the SwiftyiRate alert. It is set automatically from the application's info.plist, but you may wish to override it with a shorter or longer version.

```swift
var applicationBundleID: String?
```
This is the application bundle ID, used to retrieve the `appStoreID` and `appStoreGenreID` from iTunes. This is set automatically from the app's info.plist, so you shouldn't need to change it except for testing purposes.

```swift
var daysUntilPrompt: Float
```
This is the number of days the user must have had the app installed before they are prompted to rate it. The time is measured from the first time the app is launched. This is a floating point value, so it can be used to specify a fractional number of days (e.g. 0.5). The default value is 10 days.

```swift
var usesUntilPrompt: Int
```
This is the minimum number of times the user must launch the app before they are prompted to rate it. This avoids the scenario where a user runs the app once, doesn't look at it for weeks and then launches it again, only to be immediately prompted to rate it. The minimum use count ensures that only frequent users are prompted. The prompt will appear only after the specified number of days AND uses has been reached. This defaults to 10 uses.

```swift
var eventsUntilPrompt: Int
```
For some apps, launches are not a good metric for usage. For example the app might be a daemon that runs constantly, or a game where the user can't write an informed review until they've reached a particular level. In this case you can manually log significant events and have the prompt appear after a predetermined number of these events. Like the usesUntilPrompt setting, the prompt will appear only after the specified number of days AND events, however once the day threshold is reached, the prompt will appear if EITHER the event threshold OR uses threshold is reached. This defaults to 10 events.

```swift
var usesPerWeekForPrompt: Float
```
If you are less concerned with the total number of times the app is used, but would prefer to use the *frequency* of times the app is used, you can use the `usesPerWeekForPrompt` property to set a minimum threshold for the number of times the user must launch the app per week (on average) for the prompt to be shown. Note that this is the average since the app was installed, so if the user goes for a long period without running the app, it may throw off the average. The default value is zero.

```swift
var remindPeriod: Float
```
How long the app should wait before reminding a user to rate after they select the "remind me later" option (measured in days). A value of zero means the app will remind the user next launch. Note that this value supersedes the other criteria, so the app won't prompt for a rating during the reminder period, even if a new version is released in the meantime.  This defaults to 1 day.

```swift
var messageTitle: String
```
The title displayed for the rating prompt. If you don't want to display a title then set this to `@""`;

```swift
var message: String
```
The rating prompt message. This should be polite and courteous, but not too wordy. If you don't want to display a message then set this to `@""`;

```swift
var updateMessage: String  
```
This is a message to be used for users who have previously rated the app, encouraging them to re-rate. This allows you to customise the message for these users. If you do not supply a custom message for this case, the standard message will be used.

```swift
var cancelButtonLabel: String
```
The button label for the button to dismiss the rating prompt without rating the app.

```swift
var rateButtonLabel: String
```
The button label for the button the user presses if they do want to rate the app.

```swift
var remindButtonLabel: String
```
The button label for the button the user presses if they don't want to rate the app immediately, but do want to be reminded about it in future. Set this to `@""` if you don't want to display the remind me button - e.g. if you don't have space on screen.

```swift
var useAllAvailableLanguages: Bool
```
By default, SwiftyiRate will use all available languages in the SwiftyiRate.bundle, even if used in an app that does not support localisation. If you would prefer to restrict SwiftyiRate to only use the same set of languages that your application already supports, set this property to NO. (Defaults to YES).

```swift
var promptForNewVersionIfUserRated: Bool
```
Because iTunes ratings are version-specific, you ideally want users to rate each new version of your app. Users who really love your app may be willing to update their review for new releases. Set `promptForNewVersionIfUserRated` to `YES`, and SwiftyiRate will prompt the user again each time they install an update until they decline to rate the app. If they decline, they will not be asked again.

```swift
var onlyPromptIfLatestVersion: Bool
```
Set this to NO to enabled the rating prompt to be displayed even if the user is not running the latest version of the app. This defaults to YES because that way users won't leave bad reviews due to bugs that you've already fixed, etc.

```swift
var onlyPromptIfMainWindowIsAvailable: Bool
```
This setting is applicable to Mac OS only. By default, on Mac OS the SwiftyiRate alert is displayed as sheet on the main window. Some applications do not have a main window, so this approach doesn't work. For such applications, set this property to NO to allow the SwiftyiRate alert to be displayed as a regular modal window.

```swift
var promptAtLaunch: Bool
```
Set this to NO to disable the rating prompt appearing automatically when the application launches or returns from the background. The rating criteria will continue to be tracked, but the prompt will not be displayed automatically while this setting is in effect. You can use this option if you wish to manually control display of the rating prompt.

```swift
var verboseLogging: Bool
```
This option will cause SwiftyiRate to send detailed logs to the console about the prompt decision process. If your app is not correctly prompting for a rating when you would expect it to, this will help you figure out why. Verbose logging is enabled by default on debug builds, and disabled on release and deployment builds.

```swift
var previewMode: Bool
```
If set to YES, SwiftyiRate will always display the rating prompt on launch, regardless of how long the app has been in use or whether it's the latest version (unless you have explicitly disabled the `promptAtLaunch` option). Use this to proofread your message and check your configuration is correct during testing, but disable it for the final release (defaults to NO).


## Advanced properties
--------------

If the default SwiftyiRate behaviour doesn't meet your requirements, you can implement your own by using the advanced properties, methods and delegate. The properties below let you access internal state and override it:

```swift
var ratingsURL: NSURL?
```
The URL that the app will direct the user to so they can write a rating for the app. This is set to the correct value for the given platform automatically. On iOS 6 and below this takes users directly to the ratings page, but on iOS 7 and Mac OS it takes users to the main app page (if there is a way to directly link to the ratings page on those platforms, I've yet to find it). If you are implementing your own rating prompt, you should probably use the `openRatingsPageInAppStore` method instead, especially on Mac OS, as the process for opening the Mac app store is more complex than merely opening the URL.

```swift
var firstUsed: NSDate?
```
The first date on which the user launched the current version of the app. This is used to calculate whether the daysUntilPrompt criterion has been met.

```swift
var lastReminded: NSDate?
```
The date on which the user last requested to be reminded to rate the app later.

```swift
var usesCount: Int
```
The number of times the current version of the app has been used (launched).

```swift
var eventCount: Int
```
The number of significant application events that have been recorded since the current version was installed. This is incremented by the logEvent method, but can also be manipulated directly. Check out the *Events Demo* to see how this os used. 

```swift
var usesPerWeek: Float
```
The average number of times per week that the current version of the app has been used (launched).

```swift
var declinedThisVersion: Bool
```
This flag indicates whether the user has declined to rate the current version (YES) or not (NO). This is not currently used by the SwiftyiRate prompting logic, but may be useful for implementing your own logic.

```swift
var declinedAnyVersion: Bool
```
This flag indicates whether the user has declined to rate any previous version of the app (YES) or not (NO). SwiftyiRate will not prompt the user automatically if this is set to YES.

```swift
var ratedThisVersion: Bool
```
This flag indicates whether the user has already rated the current version (YES) or not (NO).

```swift
var ratedAnyVersion: Bool
```
This (readonly) flag indicates whether the user has previously rated any version of the app (YES) or not (NO).

```swift
weak var delegate: SwiftyiRateDelegate?
```
An object you have supplied that implements the `SwiftyiRateDelegate` protocol, documented below. Use this to detect and/or override SwiftyiRate's default behaviour. This defaults to the App Delegate, so if you are using your App Delegate as your SwiftyiRate delegate, you don't need to set this property. 


## Methods
--------------

Besides configuration, SwiftyiRate has the following methods:

```swift
func logEvent(deferPrompt: Bool)
```
This method can be called from anywhere in your app (after SwiftyiRate has been configured) and increments the SwiftyiRate significant event count. When the predefined number of events is reached, the rating prompt will be shown. The optional deferPrompt parameter is used to determine if the prompt will be shown immediately (NO) or if the app will wait until the next launch (YES).

```swift
func shouldPromptForRating() -> Bool
```
Returns YES if the prompt criteria have been met, and NO if they have not. You can use this to decide when to display a rating prompt if you have disabled the automatic display at app launch. Calling this method will not call the `iRateShouldPromptForRating` delegate method.

```swift
func promptForRating()
```
This method will immediately trigger the rating prompt without checking that the  app store is available, and without calling the SwiftyiRateShouldPromptForRating delegate method. Note that this method depends on the `appStoreID` and `applicationGenre` properties, which are only retrieved after polling the iTunes server, so if you intend to call this method directly, you will need to set these properties yourself beforehand, or use the `promptIfNetworkAvailable` method instead.

```swift
func promptIfNetworkAvailable()
```
This method will check if the app store is available, and if it is, it will display the rating prompt to the user. The SwiftyiRateShouldPromptForRating delegate method will be called before the alert is shown, so you can intercept it. Note that if your app is sandboxed and does not have the network access permission, this method will ignore the network availability status, however in this case you will need to manually set the `appStoreID` or SwiftyiRate cannot function.

```swift
func promptIfAllCriteriaMet()
```
This method will check if all prompting criteria have been met, and if the app store is available, and if it is, it will display the rating prompt to the user. The SwiftyiRateShouldPromptForRating delegate method will be called before the alert is shown, so you can intercept it.

```swift
func openRatingsPageInAppStore()
```
This method skips the user alert and opens the application ratings page in the Mac or iPhone app store, depending on which platform SwiftyiRate is running on. This method does not perform any checks to verify that the machine has network access or that the app store is available. It also does not call the `-iRateShouldOpenAppStore` delegate method. You should use this method to open the ratings page instead of the ratingsURL property, as the process for launching the app store is more complex than merely opening the URL in many cases. Note that this method depends on the `appStoreID` which is only retrieved after polling the iTunes server. If you call this method without first doing an update check, you will either need to set the `appStoreID` property yourself beforehand, or risk that the method may take some time to make a network call, or fail entirely. On success, this method will call the `-iRateDidOpenAppStore` delegate method. On Failure it will call the `-iRateCouldNotConnectToAppStore:` delegate method.


## Delegate methods
---------------

The SwiftyiRateDelegate protocol provides the following methods that can be used intercept SwiftyiRate events and override the default behaviour. All methods are optional.

```swift
optional func SwiftyiRateCouldNotConnectToAppStore(error: NSError)
```
This method is called if SwiftyiRate cannot connect to the App Store, usually because the network connection is down. This may also fire if your app does not have access to the network due to Sandbox permissions, in which case you will need to manually set the appStoreID so that SwiftyiRate can still function.

```swift
optional func SwiftyiRateDidDetectAppUpdate()
```
This method is called if SwiftyiRate detects that the application has been updated since the last time it was launched.

```swift
optional func SwiftyiRateShouldPromptForRating() -> Bool
```
This method is called immediately before the rating prompt is displayed to the user. You can use this method to implement custom prompt logic in addition to the standard rules. You can also use this method to block the standard prompt alert and display the rating prompt in a different way, or bypass it altogether.

```swift
optional func SwiftyiRateDidPromptForRating()
```
This method is called immediately before the rating prompt is displayed. This is useful if you use analytics to track what percentage of users see the prompt and then go to the app store. This can help you fine tune the circumstances around when/how you show the prompt.

```swift
optional func SwiftyiRateUserDidAttemptToRateApp()
```
This is called when the user pressed the rate button in the rating prompt. This is useful if you want to log user interaction with SwiftyiRate. This method is only called if you are using the standard SwiftyiRate alert view prompt and will not be called automatically if you provide a custom rating implementation or call the `openRatingsPageInAppStore` method directly.
   
```swift 
optional func SwiftyiRateUserDidDeclineToRateApp()
```
This is called when the user declines to rate the app. This is useful if you want to log user interaction with SwiftyiRate. This method is only called if you are using the standard SwiftyiRate alert view prompt and will not be called automatically if you provide a custom rating implementation.
   
```swift  
optional func SwiftyiRateUserDidRequestReminderToRateApp()
```
This is called when the user asks to be reminded to rate the app. This is useful if you want to log user interaction with SwiftyiRate. This method is only called if you are using the standard SwiftyiRate alert view prompt and will not be called automatically if you provide a custom rating implementation.

```swift
optional func SwiftyiRateShouldOpenAppStore() -> Bool  
```
This method is called immediately before SwiftyiRate attempts to open the app store. Return NO if you wish to implement your own ratings page display logic.

```swift
optional func SwiftyiRateDidOpenAppStore()
```
This method is called immediately after SwiftyiRate opens the app store.


## Localisation
---------------

The default strings for SwiftyiRate are already localised for many languages. By default, SwiftyiRate will use all the localisations in the SwiftyiRate.bundle even in an app that is not localised, or which is only localised to a subset of the languages that SwiftyiRate supports. The SwiftyiRate strings keys are:

```swift
public static let SwiftyiRateMessageTitleKey = "iRateMessageTitle"
public static let SwiftyiRateAppMessageKey = "iRateAppMessage"
public static let SwiftyiRateGameMessageKey = "iRateGameMessage"
public static let SwiftyiRateUpdateMessageKey = "iRateUpdateMessage"
public static let SwiftyiRateCancelButtonKey = "iRateCancelButton"
public static let SwiftyiRateRemindButtonKey = "iRateRemindButton"
public static let SwiftyiRateRateButtonKey = "iRateRateButton"
```

If you would prefer SwiftyiRate to only use the localisations that are enabled in your application (so that if your app only supports English, French and Spanish, SwiftyiRate will automatically be localised for those languages, but not for German, even though SwiftyiRate includes a German language file), set the `useAllAvailableLanguages` option to NO.

It is not recommended that you modify the strings files in the SwiftyiRate.bundle, as it will complicate updating to newer versions of SwiftyiRate. The exception to this is if you would like to submit additional languages or improvements or corrections to the localisations in the SwiftyiRate project on github (which are greatly appreciated).

If you want to add an additional language for SwiftyiRate in your app without submitting them back to the github project, you can add these strings directly to the appropriate Localizable.strings file in your project folder. If you wish to replace some or all of the default SwiftyiRate strings, the simplest option is to copy just those strings into your own Localizable.strings file and then modify them. SwiftyiRate will automatically use strings in the main application bundle in preference to the ones in the SwiftyiRate bundle so you can override any string in this way.

If you do not want to use *any* of the default localisations, you can omit the SwiftyiRate.bundle altogether. Note that if you only want to support a subset of languages that SwiftyiRate supports, it is not neccesary to delete the other strings files from SwiftyiRate.bundle - just set `useAllAvailableLanguages` to NO, and SwiftyiRate will only use the languages that your app already supports.

The old method of overriding SwiftyiRate's default strings by using individual setter methods (see below) is still supported, however the recommended approach is now to add those strings to your project's Localizable.strings file, which will be detected automatically by SwiftyiRate.

```swift
override class func initialize () {
    // overriding the default SwiftyiRate strings
    SwiftyiRate.sharedSwiftyiRate.messageTitle = NSLocalizedString("kMessageTitle", comment: "iRate message title")
    SwiftyiRate.sharedSwiftyiRate.message = NSLocalizedString("kMessage", comment: "iRate message")
    SwiftyiRate.sharedSwiftyiRate.cancelButtonLabel = NSLocalizedString("kCancelButtonLabel", comment: "Decline Button")
    SwiftyiRate.sharedSwiftyiRate.remindButtonLabel = NSLocalizedString("kRemindButtonLabel", comment: "Remind Button")
    SwiftyiRate.sharedSwiftyiRate.rateButtonLabel = NSLocalizedString("kRateButtonLabel", comment: "Rate Button")
}
```

Example Projects
---------------

When you build and run the basic Mac or iPhone example project for the first time, it will show an alert asking you to rate the app. This is because the previewMode option is set.

Disable the previewMode option and play with the other settings to see how the app behaves in practice.


Advanced Example
---------------

The advanced example demonstrates how you might implement a completely bespoke SwiftyiRate interface using the SwiftyiRateDelegate methods. Automatic prompting is disabled and instead the user can opt to rate the app by pressing the "Rate this app" button.

When pressed, the app first checks that the app store is available (it may not be if the computer has no Internet connection or apple.com is down), and then launches the Mac App Store.

The example is for Mac OS, but the same principle can be applied on iOS.


Release Notes
-----------------
Version 1.0

- Initial release.
