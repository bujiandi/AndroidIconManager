//
//  SiderController.swift
//  AndroidIconManager
//
//  Created by 慧趣小歪 on 15/6/25.
//  Copyright © 2015年 慧趣小歪. All rights reserved.
//

import Cocoa
import Util

class SideController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate, NSMenuDelegate {

    var drawables:[[File]] = []
    var mipmaps:[[File]] = []
    var headers:[String] = ["drawable","mipmap"]

    weak var viewController: ViewController!

    @IBOutlet weak var outlineView: NSOutlineView!
    
    @IBAction func onMenuDelete(sender:NSMenuItem!) {
        print(outlineView.clickedRow)
    }
    @IBAction func onMenuShowInFinder(sender:NSMenuItem!) {
        
    }
    
    func menuNeedsUpdate(menu: NSMenu) {
        let enabled = outlineView.clickedRow > 0
        menu.itemAtIndex(1)?.enabled = enabled
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.parentViewController
    }
    
    
    func reloadData() {
        
        outlineView.sizeLastColumnToFit()
        outlineView.reloadData()
        outlineView.floatsGroupRows = false
        
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration = 300
        outlineView.expandItem(nil, expandChildren: true)
        NSAnimationContext.endGrouping()
    }
    
    func reloadDataWithKeys(names:Set<String>) {
        reloadData()
        let rows:NSMutableIndexSet = NSMutableIndexSet()
        for name in names {
            rows.addIndex(outlineView.rowForItem(name))
        }
        rows.addIndexes(outlineView.selectedRowIndexes)
        outlineView.selectRowIndexes(rows, byExtendingSelection: false)
        
    }
    
    var dataSource:ImageDataSource { return ImageDataSource.shared }
    
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if item == nil {
            return headers.count
        } else if outlineView.parentForItem(item) == nil {
            //let row = outlineView.rowForItem(item)
            let dict = outlineView.rowForItem(item) == 0 ? ImageDataSource.shared.drawables : ImageDataSource.shared.mipmaps
            
            print(dict.count)
            return dict.count
        }
        
        print(0)
        return 0
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if item == nil {
            return headers[index]
        }
        let dict = outlineView.rowForItem(item) == 0 ? ImageDataSource.shared.drawables : ImageDataSource.shared.mipmaps
        let index = advance(dict.startIndex, index)
        return dict[index].0
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return outlineView.parentForItem(item) == nil
    }
    
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
        return outlineView.parentForItem(item) == nil
    }
    
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        return outlineView.parentForItem(item) != nil
    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        if outlineView.parentForItem(item) == nil {
            let index = outlineView.rowForItem(item) == 0 ? 0 : 1
            let cell = outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as! NSTableCellView
            
            cell.textField?.stringValue = headers[index]
            return cell
        }
        
        let parentRow = outlineView.rowForItem(outlineView.parentForItem(item))
        
        let currentRow = outlineView.rowForItem(item)
        
        let dict = parentRow == 0 ? ImageDataSource.shared.drawables : ImageDataSource.shared.mipmaps
        
        //print(dict)
        //print("index:\(currentRow - parentRow - 1)")
        let index = advance(dict.startIndex, currentRow - parentRow - 1)
        
        let path = dict[index].1[0].file.fullPath
        
        let cell = outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
        
        cell.imageView?.image = NSImage(contentsOfFile: path)
        cell.textField?.stringValue = dict[index].0
        cell.textField?.delegate = self
        return cell
    }
    
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        return item
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        let outlineView = notification.object as! NSOutlineView
        
        var imageItems:[[ImageItem]] = []
        for row in outlineView.selectedRowIndexes {
            let item = outlineView.itemAtRow(row)
            let dict = outlineView.rowForItem(outlineView.parentForItem(item)) == 0 ? ImageDataSource.shared.drawables : ImageDataSource.shared.mipmaps
            if let images = dict[item as! String] {
                imageItems.append(images)
            }
        }
        viewController.reloadData(imageItems)
    }
    
    var renameItem:(String, [ImageItem])? = nil
    // MARK: - NSTextFieldDelegate
    func control(control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        //print("begin:\(fieldEditor.string) ")
        let row = outlineView.rowForItem(outlineView.parentForItem(outlineView.itemAtRow(outlineView.selectedRow)))
        
        let dict = row == 0 ? ImageDataSource.shared.drawables : ImageDataSource.shared.mipmaps
        let index = advance(dict.startIndex, outlineView.selectedRow - row - 1)
        renameItem = dict[index]
        return true
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        
        guard let name = fieldEditor.string else {
            return false
        }
        
        do {
            let regular = try NSRegularExpression(pattern: "[a-z0-9_\\.]{4,}", options: NSRegularExpressionOptions(rawValue: 0))
            let stringRange = NSMakeRange(0, name.length)
            let range = regular.rangeOfFirstMatchInString(name, options: NSMatchingOptions(rawValue: 0), range: stringRange)
            if !NSEqualRanges(range, stringRange) {
                print("包涵 Android 无法识别的字符 或者 长度小于 4")
                return false
            }
            print("开始改名:\(renameItem?.0) to \(name)")
            guard let item = renameItem else {
                print("找不到要改名的文件")
                fieldEditor.string = renameItem?.0
                renameItem = nil
                return true
            }
            for imageItem:ImageItem in item.1 {
                var file:File = imageItem.file
                let fileExtension = file.fileExtension //.getFileExtension([".9.png"])
                
                if !file.rename("\(name).\(fileExtension)") {
                    print("改名失败:\(file.fullPath) to:\(name).\(fileExtension)")
                    renameItem = nil
                    return true
                }
            }
            print("改名成功 修改数据源")
            
            let row = outlineView.rowForItem(outlineView.parentForItem(outlineView.itemAtRow(outlineView.selectedRow)))

            if row == 0 {
                //let index = advance(ImageDataSource.shared.drawables.startIndex, outlineView.selectedRow - row - 1)
                //ImageDataSource.shared.drawables[index] = (name, item.1)
                ImageDataSource.shared.drawables[item.0] = nil
                ImageDataSource.shared.drawables[name] = item.1
            } else {
                ImageDataSource.shared.mipmaps[item.0] = nil
                ImageDataSource.shared.mipmaps[name] = item.1
            }
            outlineView.reloadItem(headers[row == 0 ? 0 : 1], reloadChildren: true)
        } catch {
            print("正则字符串有误")
            fieldEditor.string = renameItem?.0
        }
        renameItem = nil
        return true
    }
    
    // 当输入回车结束编辑 返回是否取消事件
    func control(control: NSControl, textView: NSTextView, doCommandBySelector commandSelector: Selector) -> Bool {
        
        if commandSelector.description == "insertNewline:" {
            textView.window?.makeFirstResponder(nil)
            return true
        }

        return false
    }

}
