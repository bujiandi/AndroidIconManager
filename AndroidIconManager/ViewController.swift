//
//  ImageController.swift
//  AndroidIconManager
//
//  Created by 慧趣小歪 on 15/6/25.
//  Copyright © 2015年 慧趣小歪. All rights reserved.
//

import Cocoa
import Util

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    weak var sideController: SideController!

    @IBOutlet weak var tableView: NSTableView!
    
    //var dataSource:ImageDataSource { return ImageDataSource.shared }

    var imageItems:[[ImageItem]] = []
    
    func reloadData(imageItems:[[ImageItem]]) {
        
        self.imageItems = imageItems
        
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置从Finder 拖入的内容是 文件URL
        tableView.registerForDraggedTypes([NSFilenamesPboardType])
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return imageItems.count;
    }
    
    /* This method is required for the "Cell Based" TableView, and is optional for the "View Based" TableView. If implemented in the latter case, the value will be set to the view at a given row/column if the view responds to -setObjectValue: (such as NSControl and NSTableCellView).
    */
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return imageItems[row][0].name
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let maxHeightImage = imageItems[row].maxElement {
            $0.image.size.height < $1.image.size.height
        }
        return (maxHeightImage?.image.size.height ?? 40) + 60
    }
    
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cell = tableView.makeViewWithIdentifier("ImageCell", owner: self) as! ImagesCellView;
        
        cell.images = imageItems[row]
        cell.textField?.stringValue = cell.images[0].name

        return cell
    }
    
    // MARK: - Drag and Drop
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        return [NSDragOperation.Every]
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        let pasteboard = info.draggingPasteboard()
        guard pasteboard.types?.contains(NSFilenamesPboardType) ?? false else {
            return false
        }
        guard let paths = pasteboard.propertyListForType(NSFilenamesPboardType) as? [String] else {
            return false
        }
        
        var names:Set<String> = Set<String>()
        //keys.insert(<#T##member: Element##Element#>)
        //var names:[String] = []
        for path in paths {
            let file = File(fullPath: path)
            
            //var success:Int = 0
            //NSWorkspace.sharedWorkspace().performFileOperation(NSWorkspaceCopyOperation, source: path.stringByDeletingLastPathComponent, destination: "/Users/bujiandi/Documents/ext", files: [file.fileName], tag: &success)
        
            let fileName = file.fileName
            let fileExtension = file.getFileExtension([".9.png"])
            
            
            let array = (fileName as NSString).stringByDeletingPathExtension.splitByString("@")
            
            let name = array.first!
            let multiple:Float = array.count <= 1 ? 1.0 : (array.last! as NSString).floatValue
            var rootPath:String = ""
            switch multiple {
            case 1.0:
                rootPath = ImageSource.drawableList[4].fullPath  //drawable-mdpi
            case 1.5:
                rootPath = ImageSource.drawableList[3].fullPath  //drawable-hdpi
            case 2.0:
                rootPath = ImageSource.drawableList[2].fullPath  //drawable-xhdpi
            case 3.0:
                rootPath = ImageSource.drawableList[1].fullPath  //drawable-xxhdpi
            case 4.0:
                rootPath = ImageSource.drawableList[0].fullPath  //drawable-xxxhdpi
            default:
                rootPath = ImageSource.drawableList[6].fullPath  //drawable
            }
            let root = File(fullPath: rootPath)
            let newFile = File(rootFile: root, fileName: "\(name).\(fileExtension)")
            
            file.copyToPath(newFile.fullPath)
            
            let item = ImageItem(newFile, root:root)
            
            if ImageSource.drawables[name] == nil {
                ImageSource.drawables[name] = []
            }
            ImageSource.drawables[name]!.insert(item, atIndex: 0)
            
            //names.append(name)
            names.insert(name)
            print("name:\(name) multiple:\(multiple) fileExtension:\(fileExtension)")

        }
        
        let oldCount = imageItems.count
        for name in names {
            imageItems.append(ImageSource.drawables[name]!)
        }
        let rows:NSIndexSet = NSIndexSet(indexesInRange: NSMakeRange(oldCount, imageItems.count - oldCount))
        
        tableView.insertRowsAtIndexes(rows, withAnimation: NSTableViewAnimationOptions.EffectGap)
        tableView.scrollRowToVisible(rows.lastIndex)
        
        //sideController.outlineView.selectRowIndexes(<#T##indexes: NSIndexSet##NSIndexSet#>, byExtendingSelection: <#T##Bool#>)
        
        sideController.reloadDataWithKeys(names)
        
        return true
    }
/*
    // 将内容拖到别的地方
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        return false
    }
*/
    
    
}
