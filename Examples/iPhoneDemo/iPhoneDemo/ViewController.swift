//
//  ViewController.swift
//  iPhoneDemo
//
//  Created by LiuYanghui on 16/5/31.
//  Copyright © 2016年 LiuYanghui. All rights reserved.
//

import UIKit
import SwiftyiRate

class ViewController: UIViewController, SwiftyiRateDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       SwiftyiRate.sharedInstance.delegate = self
    }
    
    func iRateCouldNotConnectToAppStore(error: NSError) {
        print("delegate: error: \(error.localizedDescription)")
    }
    func iRateDidDetectAppUpdate() {
        print("delegate: iRateDidDetectAppUpdate")
    }
    func iRateShouldPromptForRating() -> Bool {
        print("delegate: iRateShouldPromptForRating true")
        return true
    }
    func iRateDidPromptForRating() {
        print("delegate: iRateDidPromptForRating")
    }
    func iRateUserDidAttemptToRateApp() {
        print("delegate: iRateUserDidAttemptToRateApp")
    }
    func iRateUserDidDeclineToRateApp() {
        print("delegate: iRateUserDidDeclineToRateApp")
    }
    func iRateUserDidRequestReminderToRateApp() {
        print("delegate: iRateUserDidRequestReminderToRateApp")
    }
    func iRateShouldOpenAppStore() -> Bool {
        print("delegate: iRateShouldOpenAppStore true")
        return true
    }
    
    func iRateDidOpenAppStore() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

