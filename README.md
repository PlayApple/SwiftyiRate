#SwiftyiRate 

SwiftyiRate makes it easy to deal with rate app in Swift.

1. [Requirements](#requirements)
1. [Integration](#integration)
1. [Usage](#usage)
	- [Initialization](#initialization)

## Requirements

- iOS 7.0+
- Xcode 7

##Integration

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

####Initialization

Add code in AppDelegate.swift
```swift
import SwiftyiRate
```
```swift
override class func initialize () {
	// overriding the default iRate strings
	SwiftyiRate.sharedSwiftyiRate.messageTitle = NSLocalizedString("kMessageTitle", comment: "iRate message title")
	SwiftyiRate.sharedSwiftyiRate.message = NSLocalizedString("kMessage", comment: "iRate message")
	SwiftyiRate.sharedSwiftyiRate.cancelButtonLabel = NSLocalizedString("kCancelButtonLabel", comment: "Decline Button")
	SwiftyiRate.sharedSwiftyiRate.remindButtonLabel = NSLocalizedString("kRemindButtonLabel", comment: "Remind Button")
	SwiftyiRate.sharedSwiftyiRate.rateButtonLabel = NSLocalizedString("kRateButtonLabel", comment: "Rate Button")
}
```
