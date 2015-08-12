//
//  WindowController.swift
//  AndroidIconManager
//
//  Created by 慧趣小歪 on 15/6/24.
//  Copyright © 2015年 慧趣小歪. All rights reserved.
//

import Cocoa
import Util

var mainWindowSplitViewPosition:CGFloat = 250

extension NSSplitViewController {
    
    
    public override func viewDidAppear() {
        super.viewDidAppear()
        
        splitView.setPosition(mainWindowSplitViewPosition, ofDividerAtIndex: 0)
    }
}

class WindowController: NSWindowController, NSSplitViewDelegate {
    
    func splitView(splitView: NSSplitView, constrainSplitPosition proposedPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        mainWindowSplitViewPosition = proposedPosition < 250 ? 250 : proposedPosition
        return mainWindowSplitViewPosition
    }
    
    
    @IBOutlet weak var pathControl: NSPathControl!
    
    weak var sideController: SideController!
    weak var viewController: ViewController!
    
    @IBAction func pathChange(sender: NSPathControl) {
        print(sender.URL?.path)
        loadAndroidProjectPath(sender.URL?.path ?? "")
        //sideController.loadAndroidProgectPath(sender.URL?.path ?? "")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        //NSWorkspace
        window?.setFrame(NSMakeRect(1000, 500, 1000, 480), display: false)
        let splitController = self.contentViewController! as! NSSplitViewController
        
        splitController.splitView.delegate = self
        // 设置左侧 item 不随缩放变化
        splitController.splitView.setHoldingPriority(300, forSubviewAtIndex: 0)
        

        sideController = splitController.splitViewItems[0].viewController as! SideController
        viewController = splitController.splitViewItems[1].viewController as! ViewController
        
        sideController.viewController = viewController
        viewController.sideController = sideController
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
        
        ImageSource.drawableList = [
            File(rootFile: resFile, fileName: "drawable-xxxhdpi"),
            File(rootFile: resFile, fileName: "drawable-xxhdpi"),
            File(rootFile: resFile, fileName: "drawable-xhdpi"),
            File(rootFile: resFile, fileName: "drawable-hdpi"),
            File(rootFile: resFile, fileName: "drawable-mdpi"),
            File(rootFile: resFile, fileName: "drawable-ldpi"),
            File(rootFile: resFile, fileName: "drawable")
        ]
        ImageSource.mipmapList = [
            File(rootFile: resFile, fileName: "mipmap-xxxhdpi"),
            File(rootFile: resFile, fileName: "mipmap-xxhdpi"),
            File(rootFile: resFile, fileName: "mipmap-xhdpi"),
            File(rootFile: resFile, fileName: "mipmap-hdpi"),
            File(rootFile: resFile, fileName: "mipmap-mdpi"),
            File(rootFile: resFile, fileName: "mipmap-ldpi"),
            File(rootFile: resFile, fileName: "mipmap")
        ]
        
        let fileExtensions = ["png","jpg","jpeg"]
        
        ImageSource.drawables.removeAll()
        for drawable in ImageSource.drawableList where drawable.isExists {
            //print(drawable.fileName)
            for file in drawable.subFileList where fileExtensions.contains(file.fileExtension) {
                let name = (file.fileName as NSString).stringByDeletingPathExtension
                let item = ImageItem(file, root: drawable)

                if ImageSource.drawables[name] == nil {
                    ImageSource.drawables[name] = []
                }
                ImageSource.drawables[name]!.append(item)
            }
        }
        
        ImageSource.mipmaps.removeAll()
        for mipmap in ImageSource.mipmapList where mipmap.isExists {
            for file in mipmap.subFileList where fileExtensions.contains(file.fileExtension) {
                let name = (file.fileName as NSString).stringByDeletingPathExtension
                let item = ImageItem(file, root: mipmap)
                if ImageSource.mipmaps[name] == nil {
                    ImageSource.mipmaps[name] = []
                }
                ImageSource.mipmaps[name]!.append(item)
            }
        }
        //print(ImageDataSource.shared.drawables)
        sideController.reloadData()
    }

}

struct ImageSource {
    static var drawables:OrderedMap<String, [ImageItem]> = [:]
    static var mipmaps:OrderedMap<String, [ImageItem]> = [:]
    static var images:OrderedMap<String, OrderedMap<String, [ImageItem]>> = ["drawable":drawables, "mipmap":mipmaps]
    
    static var drawableList:[File] = []
    static var mipmapList:[File] = []
}

//class ImageDataSource {
//    
//    private struct Instance {
//        static var instance:ImageDataSource = ImageDataSource()
//    }
//    class var shared:ImageDataSource { return Instance.instance }
//    
//    var drawables:[String:[ImageItem]] = [:]
//    var mipmaps:[String:[ImageItem]] = [:]
//
//    var drawableList:[File] = []
//    var mipmapList:[File] = []
//    
//}

class ImageItem : CustomStringConvertible , CustomDebugStringConvertible {

    var root:File
    var file:File {
        didSet { _image = nil }
    }
    init (_ file:File, root:File) {
        self.file = file
        self.root = root
    }
    var name:String { return file.fileName }
    private var _image:NSImage?
    var image:NSImage {
        if _image == nil { _image = NSImage(contentsOfFile: file.fullPath) }
        return _image!
    }
    
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