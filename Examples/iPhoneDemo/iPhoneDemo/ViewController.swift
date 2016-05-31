//
//  ViewController.swift
//  iPhoneDemo
//
//  Created by LiuYanghui on 16/5/31.
//  Copyright © 2016年 LiuYanghui. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        SwiftyiRate.sharedSwiftyiRate.appStoreID = 1115972702
        SwiftyiRate.sharedSwiftyiRate.applicationBundleID = "com.cocos2dev.iBabyMusic"
        SwiftyiRate.sharedSwiftyiRate.previewMode = true
        SwiftyiRate.sharedSwiftyiRate.verboseLogging = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

