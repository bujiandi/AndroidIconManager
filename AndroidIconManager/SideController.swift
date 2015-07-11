//
//  SiderController.swift
//  AndroidIconManager
//
//  Created by 慧趣小歪 on 15/6/25.
//  Copyright © 2015年 慧趣小歪. All rights reserved.
//

import Cocoa
import Util

class SideController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate {

    var drawables:[[File]] = []
    var mipmaps:[[File]] = []
    var headers:[String] = ["drawable","mipmap"]

    weak var viewController: ViewController!

    @IBOutlet weak var outlineView: NSOutlineView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.parentViewController
    }
    
    
    func reloadData() {
        
        outlineView.sizeLastColumnToFit()
        outlineView.reloadData()
        outlineView.floatsGroupRows = false
        
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration = 0
        outlineView.expandItem(nil, expandChildren: true)
        NSAnimationContext.endGrouping()
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
    
    
    // MARK: - NSTextFieldDelegate
    func control(control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        fieldEditor.selectAll(nil)
        print("begin:\(fieldEditor.string) ")

        return true
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {

        print(fieldEditor.string)
        if fieldEditor.string!.length < 4 {
            return false
        }
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
