//
//  ImagesCellView.swift
//  AndroidIconManager
//
//  Created by 慧趣小歪 on 15/6/27.
//  Copyright © 2015年 慧趣小歪. All rights reserved.
//

import Cocoa

class ImagesCellView: NSTableCellView {
    
    
    ///*
    var imageViews:[NSImageView] = []
    var typeViews:[NSTextField] = []
    var sizeViews:[NSTextField] = []
    var images:[ImageItem] = []
    
    override func viewWillDraw() {
        super.viewWillDraw()
        //return
//        guard let images:[ImageItem] = objectValue as? [ImageItem] else {
//            return
//        }
        let interval:CGFloat = 14   // 间距
        let imageWidth:CGFloat = 48 // 图片宽度
        let moreThan = images.count - imageViews.count
        if moreThan > 0 {
            let range = imageViews.count..<images.count
            for _ in range {
                let imageView = NSImageView(frame: NSMakeRect(0, 0, imageWidth, imageWidth))
                imageView.imageScaling = NSImageScaling.ScaleAxesIndependently
                imageView.imageAlignment = NSImageAlignment.AlignCenter
                imageView.imageFrameStyle = NSImageFrameStyle.GrayBezel
                imageViews.append(imageView)
                addSubview(imageView)

                let typeView = NSTextField(frame: NSMakeRect(0, 20, imageWidth, 20))
                typeView.backgroundColor = NSColor.clearColor()
                typeView.textColor = NSColor.lightGrayColor()
                typeView.font = NSFont.systemFontOfSize(13)
                typeView.alignment = NSTextAlignment.Center
                typeView.editable = false
                typeView.selectable = false
                typeView.bezeled = false
                typeViews.append(typeView)
                addSubview(typeView)
                
                let sizeView = NSTextField(frame: NSMakeRect(0, 0, imageWidth, 20))
                sizeView.backgroundColor = NSColor.clearColor()
                sizeView.textColor = NSColor.lightGrayColor()
                sizeView.font = NSFont.systemFontOfSize(11)
                sizeView.alignment = NSTextAlignment.Center
                sizeView.editable = false
                sizeView.selectable = false
                sizeView.bezeled = false
                sizeViews.append(sizeView)
                addSubview(sizeView)
            }
        } else if moreThan < 0 {
            let range = images.count..<imageViews.count
            for i in range {
                imageViews[i].removeFromSuperview()
                typeViews[i].removeFromSuperview()
                sizeViews[i].removeFromSuperview()
            }
            imageViews.removeRange(range)
            typeViews.removeRange(range)
            sizeViews.removeRange(range)
        }
        
//        let totalWidth = (imageWidth + interval) * CGFloat(images.count) - interval
//        let width = frame.width
//        let height = (frame.height - imageWidth) / 2
//        //Swift.print("height:\(height)")
//        let x = (width - totalWidth) / 2
        let height:CGFloat = 40
        var x = interval;
        for var i=0; i<images.count; i++ {
            
            var size = images[i].image.size
            var width = size.width + interval
            if width < 48 {
                x += (48 - width) / 2
                width = 48
            }
            
            imageViews[i].setFrameOrigin(NSMakePoint(x , height))
            imageViews[i].setFrameSize(size)
            
            imageViews[i].image = images[i].image //NSImage(contentsOfFile: images[i].file.fullPath)
            typeViews[i].stringValue = images[i].root.imageRootTypeName
            sizeViews[i].stringValue = "\(Int(size.width)) x \(Int(size.height))"
            
            size.height = 20
            size.width = width
            typeViews[i].setFrameOrigin(NSMakePoint(x - interval / 2, height - 20))
            typeViews[i].setFrameSize(size)
            
            sizeViews[i].setFrameOrigin(NSMakePoint(x - interval / 2, height - 38))
            sizeViews[i].setFrameSize(size)
            x += width

        }
        //Swift.print(images[0].name)
        //if images.count !=
    }
    
    
    //*/
}
