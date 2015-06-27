//
//  ImagesCellView.swift
//  AndroidIconManager
//
//  Created by 慧趣小歪 on 15/6/27.
//  Copyright © 2015年 慧趣小歪. All rights reserved.
//

import Cocoa

class ImagesCellView: NSTableCellView {
    
    
    var images:[NSImageView] = []
    
    override func viewWillStartLiveResize() {
        super.viewWillStartLiveResize()
        print("viewWillStartLiveResize")
    }
    
    override func viewWillMoveToWindow(newWindow: NSWindow?) {
        super.viewWillMoveToWindow(newWindow)
        print("viewWillMoveToWindow")

    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
