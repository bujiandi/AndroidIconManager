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
    
    // 返回的路径用于重置 路径选择进行矫正
    func loadAndroidProgectPath(androidPath:String) -> String {
        
        outlineView.sizeLastColumnToFit()
        outlineView.reloadData()
        outlineView.floatsGroupRows = false
        
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration = 300
        outlineView.expandItem(nil, expandChildren: true)
        NSAnimationContext.endGrouping()
        
        return androidPath
    }
    
    var dataSource:ImageDataSource { return ImageDataSource.shared }
    
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if item == nil {
            return headers.count
        } else if outlineView.parentForItem(item) == nil {
            let dict = outlineView.rowForItem(item) > 0 ? dataSource.mipmaps : dataSource.drawables
            return dict.count
        }
        return 0
    }
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if item == nil {
            return headers[index]
        }
        let dict = outlineView.rowForItem(item) > 0 ? dataSource.mipmaps : dataSource.drawables
        let index = advance(dict.startIndex, index)
        return dict[index].0
    }
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return outlineView.parentForItem(item) == nil
    }
    
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
        return outlineView.parentForItem(item) == nil
    }
    
//    /* View Based OutlineView: This method is not applicable.
//    */
//    func outlineView(outlineView: NSOutlineView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) {
//        
//    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        let parentItem = outlineView.parentForItem(item)
        if parentItem == nil {
            let row = outlineView.rowForItem(item)
            let cell = outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as! NSTableCellView
            cell.textField?.stringValue = headers[row > 0 ? 1 : 0]
            return cell
        }
        
        let dict = outlineView.rowForItem(parentItem) > 0 ? dataSource.mipmaps : dataSource.drawables
        let key = item as! String
        let datas = dict[key]!
        
        //print("\(datas[0].name) § \(datas.count)\u{20DD}")
        let path = datas[0].file.fullPath
        let cell = outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
        cell.textField?.stringValue = key //"\(datas[0].name) § \(datas.count)\u{20DD}"
        cell.textField?.delegate = self
        cell.imageView?.image = NSImage(contentsOfFile: path)
        return cell
    }
    
    func outlineView(outlineView: NSOutlineView, shouldEditTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> Bool {
        return outlineView.parentForItem(item) != nil
    }
    
//    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
//        return outlineView.parentForItem(item) != nil
//    }
    
    // MARK: - Selected
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        return outlineView.parentForItem(item) != nil
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        let outlineView = notification.object as! NSOutlineView
        outlineViewSelectionsDidChange(outlineView)
    }
    func outlineViewSelectionsDidChange(outlineView:NSOutlineView) {
        
        var keys:[String] = []
        for row in outlineView.selectedRowIndexes {
            if let key = outlineView.itemAtRow(row) as? String {
                keys.append(key)
            }
        }
        viewController.reloadData(keys)
        print("keys:\(keys) set:\(outlineView.selectedRowIndexes)")
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
