//
//  SwiftyiRate.swift
//  SwiftyiRate
//
//  Created by LiuYanghui on 16/5/31.
//  Copyright © 2016年 LiuYanghui. All rights reserved.
//

import Foundation
import UIKit
import CoreFoundation

enum SwiftyiRateErrorCode : Int {
    case iRateErrorBundleIdDoesNotMatchAppStore
    case iRateErrorApplicationNotFoundOnAppStore
    case iRateErrorApplicationIsNotLatestVersion
    case iRateErrorCouldNotOpenRatingPageURL
}


private let iRateAppStoreGameGenreID = 6014
private let iRateErrorDomain = "iRateErrorDomain"

private let iRateMessageTitleKey = "iRateMessageTitle"
private let iRateAppMessageKey = "iRateAppMessage"
private let iRateGameMessageKey = "iRateGameMessage"
private let iRateUpdateMessageKey = "iRateUpdateMessage"
private let iRateCancelButtonKey = "iRateCancelButton"
private let iRateRemindButtonKey = "iRateRemindButton"
private let iRateRateButtonKey = "iRateRateButton"

public let iRateCouldNotConnectToAppStore = "iRateCouldNotConnectToAppStore"
public let iRateDidDetectAppUpdate = "iRateDidDetectAppUpdate"
public let iRateDidPromptForRating = "iRateDidPromptForRating"
public let iRateUserDidAttemptToRateApp = "iRateUserDidAttemptToRateApp"
public let iRateUserDidDeclineToRateApp = "iRateUserDidDeclineToRateApp"
public let iRateUserDidRequestReminderToRateApp = "iRateUserDidRequestReminderToRateApp"
public let iRateDidOpenAppStore = "iRateDidOpenAppStore"

private let iRateAppStoreIDKey = "iRateAppStoreID"
private let iRateRatedVersionKey = "iRateRatedVersionChecked"
private let iRateDeclinedVersionKey = "iRateDeclinedVersion"
private let iRateLastRemindedKey = "iRateLastReminded"
private let iRateLastVersionUsedKey = "iRateLastVersionUsed"
private let iRateFirstUsedKey = "iRateFirstUsed"
private let iRateUseCountKey = "iRateUseCount"
private let iRateEventCountKey = "iRateEventCount"

private let iRateMacAppStoreBundleID = "com.apple.appstore"
private let iRateAppLookupURLFormat = "https://itunes.apple.com/%@/lookup"

private let iRateiOSAppStoreURLScheme = "itms-apps"
private let iRateiOSAppStoreURLFormat = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d&pageNumber=0&sortOrdering=2&mt=8"
private let iRateiOS7AppStoreURLFormat = "itms-apps://itunes.apple.com/app/id%d"
private let iRateMacAppStoreURLFormat = "macappstore://itunes.apple.com/app/id%d"

private let SECONDS_IN_A_DAY: Float  = 86400.0
private let SECONDS_IN_A_WEEK: Float = 604800.0
private let MAC_APP_STORE_REFRESH_DELAY: Float = 5.0
private let REQUEST_TIMEOUT: Double = 60.0

private let sharedSwiftyiRate = SwiftyiRate()
public class SwiftyiRate: NSObject {
    
    public class var sharedInstance: SwiftyiRate {
        return sharedSwiftyiRate
    }
    
    // app store ID - this is only needed if your
    // bundle ID is not unique between iOS and Mac app stores
    lazy var appStoreID: Int? = {
        return NSUserDefaults.standardUserDefaults().objectForKey(iRateAppStoreIDKey)?.integerValue
    }()
    
    // application details - these are set automatically
    private var appStoreGenreID: Int?
    private var appStoreCountry: String
    private var applicationName: String
    private var applicationVersion: String
    public var applicationBundleID: String?
    
    // usage settings - these have sensible defaults
    public var usesUntilPrompt: Int
    public var eventsUntilPrompt: Int
    public var daysUntilPrompt: Float
    public var usesPerWeekForPrompt: Float
    public var remindPeriod: Float
    
    // message text, you may wish to customise these
    lazy public var messageTitle: String = {
        return self.localizedStringForKey(iRateMessageTitleKey, withDefault: "Rate %@").stringByReplacingOccurrencesOfString("%@", withString: self.applicationName)
    }()
    lazy public var message: String = {
        var defaultMessage = (self.appStoreGenreID! == 6014) ?
            self.localizedStringForKey(iRateGameMessageKey, withDefault: "If you enjoy playing %@, would you mind taking a moment to rate it? It won’t take more than a minute. Thanks for your support!") :
            self.localizedStringForKey(iRateAppMessageKey, withDefault: "If you enjoy using %@, would you mind taking a moment to rate it? It won’t take more than a minute. Thanks for your support!")
        return defaultMessage.stringByReplacingOccurrencesOfString("%@", withString: self.applicationName)
    }()
    lazy public var updateMessage: String = {
        var defaultMessage = self.localizedStringForKey(iRateUpdateMessageKey, withDefault: self.message)
        return defaultMessage.stringByReplacingOccurrencesOfString("%@", withString: self.applicationName)
    }()
    lazy public var cancelButtonLabel: String = {
        return self.localizedStringForKey(iRateCancelButtonKey, withDefault: "No, Thanks")
    }()
    lazy public var remindButtonLabel: String = {
        return self.localizedStringForKey(iRateRemindButtonKey, withDefault: "Remind Me Later")
    }()
    lazy public var rateButtonLabel: String = {
        return self.localizedStringForKey(iRateRateButtonKey, withDefault: "Rate It Now")
    }()
    
    //debugging and prompt overrides
    public var useAllAvailableLanguages = true
    public var promptForNewVersionIfUserRated: Bool
    public var onlyPromptIfLatestVersion: Bool
    public var onlyPromptIfMainWindowIsAvailable: Bool
    public var promptAtLaunch: Bool
    public var verboseLogging = false {
        didSet{
            if verboseLogging {
                print("SwiftyiRate verbose logging enabled.");
            }
        }
    }
    public var previewMode: Bool
    
    //advanced properties for implementing custom behaviour
    lazy public var ratingsURL: NSURL? = {
        if self.appStoreID <= 0 {
            self.printLog("iRate could not find the App Store ID for this application. If the application is not intended for App Store release then you must specify a custom ratingsURL.")
            return nil
        }
        var URLString = iRateiOSAppStoreURLFormat
        let iOSVersion = Float(UIDevice.currentDevice().systemVersion)
        if iOSVersion >= 7.0 && iOSVersion < 7.1 {
            URLString = iRateiOS7AppStoreURLFormat
        }
        return NSURL(string: String(format: URLString, self.appStoreID!))
    }()
    public var firstUsed: NSDate? {
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: iRateFirstUsedKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get{
            return NSUserDefaults.standardUserDefaults().objectForKey(iRateFirstUsedKey) as? NSDate
        }
    }
    public var lastReminded: NSDate? {
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: iRateLastRemindedKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get{
            return NSUserDefaults.standardUserDefaults().objectForKey(iRateLastRemindedKey) as? NSDate
        }
    }
    public var usesCount: Int {
        set{
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: iRateUseCountKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get{
            return NSUserDefaults.standardUserDefaults().integerForKey(iRateUseCountKey)
        }
    }
    public var eventCount: Int {
        set{
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: iRateEventCountKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get{
            return NSUserDefaults.standardUserDefaults().integerForKey(iRateEventCountKey)
        }
    }
    public var usesPerWeek: Float {
        if self.usesCount > 0 && self.firstUsed != nil {
            return Float(self.usesCount) / (Float(NSDate().timeIntervalSinceDate(self.firstUsed!)) / SECONDS_IN_A_WEEK)
        }
        return 0
    }
    
    public var declinedThisVersion: Bool {
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue ? self.applicationVersion : nil, forKey: iRateDeclinedVersionKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get{
            if let version = NSUserDefaults.standardUserDefaults().objectForKey(iRateDeclinedVersionKey) as? String {
                return version == self.applicationVersion
            }
            return false
        }
    }
    public var declinedAnyVersion: Bool {
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey(iRateDeclinedVersionKey) {
            return true
        }
        return false
    }
    public func ratedVersion(version: String) -> Bool {
        if let ratedVersion = NSUserDefaults.standardUserDefaults().objectForKey(iRateRatedVersionKey) as? String {
            return ratedVersion == version
        }
        return false
    }
    public var ratedThisVersion: Bool {
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue ? self.applicationVersion : nil, forKey: iRateRatedVersionKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get{
            return self.ratedVersion(self.applicationVersion)
        }
    }
    public var ratedAnyVersion: Bool {
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey(iRateRatedVersionKey) {
            return true
        }
        return false
    }
    weak var delegate: SwiftyiRateDelegate?
    
    private var visibleAlert: UIAlertController?
    private var checkingForPrompt: Bool = false
    private var checkingForAppStoreID: Bool = false
    
    lazy private var bundle: NSBundle = {
        var bundle: NSBundle
        var bundlePath = NSBundle(forClass: SwiftyiRate.self).pathForResource("SwiftyiRate", ofType: "bundle")
        if self.useAllAvailableLanguages {
            bundle = NSBundle(path: bundlePath!)!
            var language = NSLocale.preferredLanguages().count > 0 ? NSLocale.preferredLanguages()[0] : "en"
            if bundle.localizations.contains(language) == false {
                language = language.componentsSeparatedByString("-")[0]
            }
            if bundle.localizations.contains(language) {
                bundlePath = bundle.pathForResource(language, ofType: "lproj")
            }
        }
        if let newBundle = NSBundle(path: bundlePath!) {
            bundle = newBundle
        } else {
            bundle = NSBundle.mainBundle()
        }
        return bundle
    }()
    
    // MARK: - Lift circle
    override private init() {
        // get country
        if let countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String {
            self.appStoreCountry = countryCode
            if self.appStoreCountry == "150" {
                self.appStoreCountry = "eu"
            } else if self.appStoreCountry == "GI" {
                self.appStoreCountry = "GB"
            } else if self.appStoreCountry.stringByReplacingOccurrencesOfString("[A-Za-z]{2}", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: self.appStoreCountry.startIndex.advancedBy(0) ..< self.appStoreCountry.startIndex.advancedBy(2)).characters.count > 0 {
                self.appStoreCountry = "us"
            }
        } else {
            self.appStoreCountry = "us"
        }
        
        // application version (use short version preferentially)
        self.applicationVersion = ""
        if let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
            self.applicationVersion = version
        } else if let version = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as? String {
            self.applicationVersion = version
        }
        
        // localised application name
        self.applicationName = ""
        if let appName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleDisplayName") as? String {
            self.applicationName = appName
        } else if let appName = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleNameKey as String) as? String {
            self.applicationName = appName
        }
        
        // bundle id
        if let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier {
            self.applicationBundleID = bundleIdentifier
        }
        
        // default settings
        self.useAllAvailableLanguages = true
        self.promptForNewVersionIfUserRated = false
        self.onlyPromptIfLatestVersion = true
        self.onlyPromptIfMainWindowIsAvailable = true
        self.promptAtLaunch = true
        self.usesUntilPrompt = 10
        self.eventsUntilPrompt = 10
        self.daysUntilPrompt = 10.0
        self.usesPerWeekForPrompt = 0.0
        self.remindPeriod = 1.0
        self.verboseLogging = false
        self.previewMode = false
        
        super.init()
        
        //register for iphone application events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SwiftyiRate.applicationWillEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        //app launched
        self.performSelectorOnMainThread(#selector(SwiftyiRate.applicationLaunched), withObject: nil, waitUntilDone: false)
    }
    
    
    // MARK: - Private method
    private func printLog(items: Any...) {
        if self.verboseLogging {
            print(items)
        }
    }
    
    private func incrementUseCount() {
        self.usesCount += 1
    }
    
    private func incrementEventCount() {
        self.eventCount += 1
    }
    
    /// 本地化String
    private func localizedStringForKey(key: String, withDefault defaultString: String) -> String {
        let newDefaultString = bundle.localizedStringForKey(key, value: defaultString, table: nil)
        return NSBundle.mainBundle().localizedStringForKey(key, value: newDefaultString, table: nil)
    }
    
    // MARK: - Manually control behaviour
    /// 通过对上面各个配置参数的检查，返回YES可以提醒，NO不满足
    private func shouldPromptForRating() -> Bool {
        // preview mode
        if self.previewMode {
            print("SwiftyiRate preview mode is enabled - make sure you disable this for release")
            return true
        }
        
        // check if we've rated this version
        if self.ratedThisVersion {
            printLog("SwiftyiRate did not prompt for rating because the user has already rated this version")
            return false
        }
        
        // check if we've rated any version
        if self.ratedAnyVersion && !self.promptForNewVersionIfUserRated {
            printLog("iRate did not prompt for rating because the user has already rated this app, and promptForNewVersionIfUserRated is disabled")
            return false
        }
        
        // check if we've declined to rate the app
        if self.declinedAnyVersion {
            printLog("iRate did not prompt for rating because the user has declined to rate the app")
            return false
        }
        
        // check how long we've been using this version
        if self.firstUsed == nil ||
            (Float(NSDate().timeIntervalSinceDate(self.firstUsed!)) < self.daysUntilPrompt * SECONDS_IN_A_DAY){
            printLog("iRate did not prompt for rating because the app was first used less than \(self.daysUntilPrompt) days ago")
            return false
        }
        
        // check how many times we've used it and the number of significant events
        if self.usesCount < self.usesUntilPrompt && self.eventCount < self.eventsUntilPrompt {
            printLog("iRate did not prompt for rating because the app has only been used \(self.usesCount) times and only \(self.eventCount) events have been logged")
            return false
        }
        
        // check if usage frequency is high enough
        if (self.usesPerWeek < self.usesPerWeekForPrompt) {
            printLog("iRate did not prompt for rating because the app has only been used \(self.usesPerWeek) times per week on average since it was installed")
            return false
        }
        
        // check if within the reminder period
        if self.lastReminded != nil && (Float(NSDate().timeIntervalSinceDate(self.lastReminded!)) < self.remindPeriod * SECONDS_IN_A_DAY) {
            printLog("iRate did not prompt for rating because the user last asked to be reminded less than \(self.remindPeriod) days ago")
            return false
        }
        
        // lets prompt!
        return true
    }
    
    /// 设置 app store ID
    private func setAppStoreIDOnMainThread(appStoreID: Int) {
        self.appStoreID = appStoreID
        NSUserDefaults.standardUserDefaults().setInteger(self.appStoreID!, forKey: iRateAppStoreIDKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func connectionSucceeded() {
        if self.checkingForAppStoreID == true {
            // no longer checking
            self.checkingForPrompt = false
            self.checkingForAppStoreID = false
            
            // open app store
            openRatingsPageInAppStore()
        } else if self.checkingForPrompt == true {
            // no longer checking
            self.checkingForPrompt = false
            
            // confirm with delegate
            if let delegate = self.delegate {
                if delegate.iRateShouldPromptForRating!() == false {
                    printLog("iRate did not display the rating prompt because the iRateShouldPromptForRating delegate method returned false")
                    return
                }
            }
            
            // prompt user
            promptForRating()
        }
    }
    
    private func connectionError(error: NSError?) {
        if self.checkingForPrompt == true || self.checkingForAppStoreID == true {
            // no longer checking
            self.checkingForPrompt = false
            self.checkingForAppStoreID = false
            
            // log the error
            if (error != nil) {
                printLog("iRate rating process failed because: \(error!.localizedDescription)")
            } else {
                printLog("iRate rating process failed because an unknown error occured")
            }
            
            // could not connect
            self.delegate?.iRateCouldNotConnectToAppStore!(error!)
            
            NSNotificationCenter.defaultCenter().postNotificationName(iRateCouldNotConnectToAppStore, object: error)
        }
        
        
    }
    
    private var inCheckingBackground = false
    private func checkForConnectivityInBackground() {
        if inCheckingBackground {
            return
        }
        inCheckingBackground = true
        
        let operation = NSBlockOperation { () -> Void in
            // first check iTunes
            var iTunesServiceURL = String(format: iRateAppLookupURLFormat, self.appStoreCountry)
            if self.appStoreID > 0 { //important that we check ivar and not getter in case it has changed
                iTunesServiceURL += "?id=\(self.appStoreID!)"
            } else {
                iTunesServiceURL += "?bundleId=\(self.applicationBundleID!)"
            }
            self.printLog("iRate is checking \(iTunesServiceURL) to retrieve the App Store details...")
            
            let url = NSURL(string: iTunesServiceURL)!
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                let response = response as! NSHTTPURLResponse
                var returnError = error
                defer {
                    // handle errors (ignoring sandbox issues)
                    if returnError?.code == Int(EPERM) && returnError?.domain == NSPOSIXErrorDomain && self.appStoreID > 0 {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.connectionError(returnError)
                        })
                    } else if self.appStoreID > 0 || self.previewMode {
                        // show prompt
                        dispatch_async(dispatch_get_main_queue(), {
                            self.connectionSucceeded()
                        })
                    }
                    self.inCheckingBackground = false
                }
                guard response.statusCode != 200 else {
                    // http error
                    returnError = NSError(domain: "HTTPResponseErrorDomain", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "The server returned a \(response.statusCode) error"])
                    return
                }
                guard let data = data else {
                    // empty response
                    returnError = NSError(domain: "HTTPResponseErrorDomain", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "The server returned an empty response"])
                    return
                }
                let json: AnyObject?
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                } catch let error as NSError {
                    returnError = error
                    return
                }
                guard let resultsJson = (json?.objectForKey("results") as? [AnyObject])?[0] else {
                    returnError = NSError(domain: "HTTPResponseErrorDomain", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "The server returned an invalid JSON"])
                    return
                }
                if let bundleID = resultsJson.objectForKey("bundleId") as? String {
                    if bundleID == self.applicationBundleID {
                        // get genre
                        if self.appStoreGenreID == nil {
                            self.appStoreGenreID = resultsJson.objectForKey("primaryGenreId") as? Int
                        }
                        
                        // get app id
                        if self.appStoreID <= 0 {
                            let appStoreID = resultsJson.objectForKey("trackId") as? Int
                            self.printLog("iRate found the app on iTunes. The App Store ID is \(appStoreID)")
                            dispatch_async(dispatch_get_main_queue(), {
                                self.setAppStoreIDOnMainThread(appStoreID!)
                            })
                        }
                        
                        // check version
                        if self.onlyPromptIfLatestVersion && self.previewMode == false {
                            let latestVersion = resultsJson.objectForKey("version") as! String
                            if latestVersion.compare(self.applicationVersion, options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedDescending {
                                // latestVersion number is larger than self.applicationVersion number
                                self.printLog("SwiftyiRate found that the installed application version (\(self.applicationVersion)) is not the latest version on the App Store, which is \(latestVersion)")
                                
                                returnError = NSError(domain: iRateErrorDomain, code: SwiftyiRateErrorCode.iRateErrorBundleIdDoesNotMatchAppStore.rawValue, userInfo: [NSLocalizedDescriptionKey: "Installed app is not the latest version available"])
                            }
                        }
                    } else {
                        self.printLog("SwiftyiRate found that the application bundle ID (\(self.applicationBundleID)) does not match the bundle ID of the app found on iTunes (\(bundleID)) with the specified App Store ID (\(self.appStoreID))")
                        
                        returnError = NSError(domain: iRateErrorDomain, code: SwiftyiRateErrorCode.iRateErrorBundleIdDoesNotMatchAppStore.rawValue, userInfo: [NSLocalizedDescriptionKey: "Application bundle ID does not match expected value of \(bundleID)"])
                        
                    }
                } else if self.appStoreID > 0 || self.ratingsURL == nil {
                    self.printLog("SwiftyiRate could not find this application on iTunes. If your app is not intended for App Store release then you must specify a custom ratingsURL. If this is the first release of your application then it's not a problem that it cannot be found on the store yet")
                    if self.previewMode == false {
                        returnError = NSError(domain: iRateErrorDomain, code: SwiftyiRateErrorCode.iRateErrorApplicationNotFoundOnAppStore.rawValue, userInfo: [NSLocalizedDescriptionKey: "The application could not be found on the App Store."])
                    }
                } else if self.appStoreID <= 0{
                    self.printLog("SwiftyiRate could not find your app on iTunes. If your app is not yet on the store or is not intended for App Store release then don't worry about this");
                }
                
            })
            task.resume()
            
        }
        let operationQueue = NSOperationQueue()
        operationQueue.addOperation(operation)
    }
    
    /// 如果网络有效将检查AppStore的App信息
    private func promptIfNetworkAvailable() {
        if (self.checkingForPrompt == false && self.checkingForAppStoreID == false) {
            self.checkingForPrompt = true
            checkForConnectivityInBackground()
        }
    }
    
    /// 检查shouldPromptForRating和promptIfNetworkAvailable方法是否满足
    private func promptIfAllCriteriaMet() {
        if shouldPromptForRating() {
            promptIfNetworkAvailable()
        }
    }
    
    private func showRemindButton() -> Bool {
        return self.remindButtonLabel.characters.count > 0
    }
    
    private func showCancelButton() -> Bool {
        return self.cancelButtonLabel.characters.count > 0
    }
    
    /// 弹出提醒
    private func promptForRating() {
        if self.visibleAlert == nil {
            let message = self.ratedAnyVersion ? self.updateMessage : self.message
            
            var topController = UIApplication.sharedApplication().keyWindow?.rootViewController
            while ((topController?.presentedViewController) != nil) {
                topController = topController?.presentedViewController
            }
            
            let alert = UIAlertController(title: self.messageTitle, message: message, preferredStyle: .Alert)
            
            // rate action
            let rateAction = UIAlertAction(title: self.rateButtonLabel, style: .Default, handler: {(action) -> Void in
                self.rate()
            })
            alert.addAction(rateAction)
            
            // remind action
            if showRemindButton() {
                let remindAction = UIAlertAction(title: self.remindButtonLabel, style: .Default, handler: {(action) -> Void in
                    self.remindLater()
                })
                alert.addAction(remindAction)
            }
            
            // cancel action
            if showCancelButton() {
                let cancelAction = UIAlertAction(title: self.cancelButtonLabel, style: .Cancel, handler: {(action) -> Void in
                    self.declineThisVersion()
                })
                alert.addAction(cancelAction)
            }
            
            self.visibleAlert = alert
            // get current view controller and present alert
            topController!.presentViewController(alert, animated: true, completion: nil)
            
            // inform about prompt
            self.delegate?.iRateDidPromptForRating!()
            NSNotificationCenter.defaultCenter().postNotificationName(iRateDidPromptForRating, object: nil)
        }
    }
    
    // MARK: - Action
    func applicationLaunched() {
        // check if this is a new version
        let defaults = NSUserDefaults.standardUserDefaults()
        let lastUsedVersion = defaults.objectForKey(iRateLastVersionUsedKey) as? String ?? ""
        if self.firstUsed == nil || lastUsedVersion != self.applicationVersion {
            defaults.setObject(self.applicationVersion, forKey: iRateLastVersionUsedKey)
            if (self.firstUsed == nil || self.ratedAnyVersion) {
                // reset defaults
                defaults.setObject(NSDate(), forKey: iRateFirstUsedKey)
                defaults.setInteger(0, forKey: iRateUseCountKey)
                defaults.setInteger(0, forKey: iRateEventCountKey)
                defaults.setObject(nil, forKey: iRateLastRemindedKey)
                defaults.synchronize()
            } else if Float(NSDate().timeIntervalSinceDate(self.firstUsed!)) > (self.daysUntilPrompt - 1) * SECONDS_IN_A_DAY {
                // if was previously installed, but we haven't yet prompted for a rating
                // don't reset, but make sure it won't rate for a day at least
                self.firstUsed = NSDate().dateByAddingTimeInterval(Double((self.daysUntilPrompt - 1) * -SECONDS_IN_A_DAY))
            }
            
            // inform about app update
            self.delegate?.iRateDidDetectAppUpdate!()
            NSNotificationCenter.defaultCenter().postNotificationName(iRateDidDetectAppUpdate, object: nil)
        }
        
        incrementUseCount()
        checkForConnectivityInBackground()
        if self.promptAtLaunch {
            promptIfAllCriteriaMet()
        }
    }
    
    /// application will enter foreground
    func applicationWillEnterForeground() {
        if UIApplication.sharedApplication().applicationState == .Background {
            incrementUseCount()
            checkForConnectivityInBackground()
            if self.promptAtLaunch {
                promptIfAllCriteriaMet()
            }
        }
    }
    
    /// 打开打分提醒AppStore页面
    private func openRatingsPageInAppStore() {
        if (self.ratingsURL == nil && self.appStoreID <= 0) {
            self.checkingForAppStoreID = true
            if self.checkingForPrompt == false {
                checkForConnectivityInBackground()
            }
            return
        }
        
        var cantOpenMessage: String?
        #if TARGET_OS_SIMULATOR
            if self.ratingsURL?.scheme == iRateiOSAppStoreURLScheme {
                cantOpenMessage = "iRate could not open the ratings page because the App Store is not available on the iOS simulator";
            }
        #endif
        if UIApplication.sharedApplication().canOpenURL(self.ratingsURL!) == false {
            cantOpenMessage = "iRate was unable to open the specified ratings URL: \(self.ratingsURL!)"
        }
        
        if cantOpenMessage != nil {
            printLog(cantOpenMessage)
            let error = NSError(domain: iRateErrorDomain, code: SwiftyiRateErrorCode.iRateErrorCouldNotOpenRatingPageURL.rawValue, userInfo: [NSLocalizedDescriptionKey: cantOpenMessage!])
            self.delegate?.iRateCouldNotConnectToAppStore!(error)
            NSNotificationCenter.defaultCenter().postNotificationName(iRateCouldNotConnectToAppStore, object: error)
        } else {
            printLog("iRate will open the App Store ratings page using the following URL: \(self.ratingsURL!)")
            
            UIApplication.sharedApplication().openURL(self.ratingsURL!)
            self.delegate?.iRateDidOpenAppStore!()
            NSNotificationCenter.defaultCenter().postNotificationName(iRateDidOpenAppStore, object: nil)
        }
        
    }
    
    /// 发生事件进行添加
    public func logEvent(deferPrompt: Bool) {
        incrementEventCount()
        if deferPrompt == false {
            promptIfAllCriteriaMet()
        }
    }
    
    // MARK: - User action
    func declineThisVersion() {
        // ignore this version
        self.declinedThisVersion = true
        
        // log event
        self.delegate?.iRateUserDidDeclineToRateApp!()
        NSNotificationCenter.defaultCenter().postNotificationName(iRateUserDidDeclineToRateApp, object: nil)
    }
    
    func remindLater() {
        // remind later
        self.lastReminded = NSDate()
        
        // log event
        self.delegate?.iRateUserDidRequestReminderToRateApp!()
        NSNotificationCenter.defaultCenter().postNotificationName(iRateUserDidRequestReminderToRateApp, object: nil)
    }
    
    func rate() {
        // mark as rated
        self.ratedThisVersion = true
        
        // log event
        self.delegate?.iRateUserDidAttemptToRateApp!()
        NSNotificationCenter.defaultCenter().postNotificationName(iRateUserDidAttemptToRateApp, object: nil)
        
        if let delegate = self.delegate {
            if delegate.iRateShouldOpenAppStore!() {
                // launch mac app store
                openRatingsPageInAppStore()
            }
        }
    }
}

// MARK: - Protocol
@objc protocol SwiftyiRateDelegate{
    optional func iRateCouldNotConnectToAppStore(error: NSError)
    optional func iRateDidDetectAppUpdate()
    optional func iRateShouldPromptForRating() -> Bool
    optional func iRateDidPromptForRating()
    optional func iRateUserDidAttemptToRateApp()
    optional func iRateUserDidDeclineToRateApp()
    optional func iRateUserDidRequestReminderToRateApp()
    optional func iRateShouldOpenAppStore() -> Bool
    optional func iRateDidOpenAppStore()
}
