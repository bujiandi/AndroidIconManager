//
//  AppDelegate.swift
//  AndroidIconManager
//
//  Created by 慧趣小歪 on 15/6/12.
//  Copyright © 2015年 慧趣小歪. All rights reserved.
//

import Cocoa
import Util

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let str = " \n\r Hello, playground \r\n "
        let m:Character = "\u{65}\u{301}\u{20DD}"
        
        let tttt = str.trim()
        print(tttt)
        print(m.hashValue)

        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

