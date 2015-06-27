//
//  WindowController.swift
//  AndroidIconManager
//
//  Created by 慧趣小歪 on 15/6/24.
//  Copyright © 2015年 慧趣小歪. All rights reserved.
//

import Cocoa
import Util

class WindowController: NSWindowController {
    
    @IBOutlet weak var pathControl: NSPathControl!
    
    weak var sideController: SideController!
    weak var imageController: ImageController!
    
    @IBAction func pathChange(sender: NSPathControl) {
        print(sender.URL?.path)
        
        loadAndroidProjectPath(sender.URL?.path ?? "")
        //sideController.loadAndroidProgectPath(sender.URL?.path ?? "")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let splitController = self.contentViewController as? NSSplitViewController
        splitController!.splitView.setPosition(100, ofDividerAtIndex: 0)
        sideController = splitController!.splitViewItems[0].viewController as! SideController
        imageController = splitController!.splitViewItems[1].viewController as! ImageController
        
        sideController.imageController = imageController
        imageController.sideController = sideController
        //sideController.loadAndroidProgectPath(pathControl.URL?.path ?? "")
        
        loadAndroidProjectPath("/Users/bujiandi/Documents/Android/ExamReader/reader")
    }
    
    
    func loadAndroidProjectPath(path:String) {
        if path.isEmpty { return }
        let rootFile:File = File(fullPath: path)
        
        if !rootFile.isDirectory { return }
        
        if existsProject(rootFile) {
            loadAndroidProjectImages(rootFile)
            return
        }
        for file in rootFile.subFileList {
            if existsProject(file) {
                loadAndroidProjectImages(file)
                return
            }
        }
    }
    
    func existsProject(rootFile:File) -> Bool {
        if !rootFile.isDirectory { return false }
        return rootFile.existsFileName(["src","libs","build"])
    }
    
    func loadAndroidProjectImages(rootFile:File) {
        let resFile = File(rootFile: rootFile, fileName: "src/main/res")
        
        ImageDataSource.shared.drawableList = [
            File(rootFile: resFile, fileName: "drawable"),
            File(rootFile: resFile, fileName: "drawable-ldpi"),
            File(rootFile: resFile, fileName: "drawable-mdpi"),
            File(rootFile: resFile, fileName: "drawable-hdpi"),
            File(rootFile: resFile, fileName: "drawable-xhdpi"),
            File(rootFile: resFile, fileName: "drawable-xxhdpi"),
            File(rootFile: resFile, fileName: "drawable-xxxhdpi")
        ]
        ImageDataSource.shared.mipmapList = [
            File(rootFile: resFile, fileName: "mipmap"),
            File(rootFile: resFile, fileName: "mipmap-ldpi"),
            File(rootFile: resFile, fileName: "mipmap-mdpi"),
            File(rootFile: resFile, fileName: "mipmap-hdpi"),
            File(rootFile: resFile, fileName: "mipmap-xhdpi"),
            File(rootFile: resFile, fileName: "mipmap-xxhdpi"),
            File(rootFile: resFile, fileName: "mipmap-xxxhdpi")
        ]
        
        let fileExtensions = ["png","jpg","jpeg"]
        
        ImageDataSource.shared.drawables = [:]
        for drawable in ImageDataSource.shared.drawableList where drawable.isExists {
            //print(drawable.fileName)
            for file in drawable.subFileList where fileExtensions.contains(file.fileExtension) {
                let name = file.fileName.stringByDeletingPathExtension
                let item = ImageItem(file, root: drawable)

                if ImageDataSource.shared.drawables[name] == nil {
                    ImageDataSource.shared.drawables[name] = []
                }
                ImageDataSource.shared.drawables[name]!.append(item)
            }
        }
        
        ImageDataSource.shared.mipmaps = [:]
        for mipmap in ImageDataSource.shared.mipmapList where mipmap.isExists {
            for file in mipmap.subFileList where fileExtensions.contains(file.fileExtension) {
                let name = file.fileName.stringByDeletingPathExtension
                let item = ImageItem(file, root: mipmap)
                if ImageDataSource.shared.mipmaps[name] == nil {
                    ImageDataSource.shared.mipmaps[name] = []
                }
                ImageDataSource.shared.mipmaps[name]!.append(item)
            }
        }
        //print(ImageDataSource.shared.drawables)
        sideController.reloadData()
    }

}

class ImageDataSource {
    
    private struct Instance {
        static var instance:ImageDataSource = ImageDataSource()
    }
    class var shared:ImageDataSource { return Instance.instance }
    
    var drawables:[String:[ImageItem]] = [:]
    var mipmaps:[String:[ImageItem]] = [:]

    var drawableList:[File] = []
    var mipmapList:[File] = []
    
}

class ImageItem : CustomStringConvertible , CustomDebugStringConvertible {
    var file:File
    var root:File
    init (_ file:File, root:File) {
        self.file = file
        self.root = root
    }
    var name:String { return file.fileName }
    
    var description: String { return file.fileName + "(\(root.imageRootTypeName))" }
    var debugDescription: String { return description }

}

extension File {
    
    var imageRootTypeName:String {
        let types = self.fileName.splitByString("-")
        if types.count == 2 { return types[1] }
        return ""
    }
    
}