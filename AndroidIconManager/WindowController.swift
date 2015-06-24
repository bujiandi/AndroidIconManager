//
//  WindowController.swift
//  AndroidIconManager
//
//  Created by 慧趣小歪 on 15/6/24.
//  Copyright © 2015年 慧趣小歪. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    @IBOutlet weak var pathControl: NSPathControl!
    
    @IBAction func pathChange(sender: NSPathControl) {
        print(sender.URL?.path)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
