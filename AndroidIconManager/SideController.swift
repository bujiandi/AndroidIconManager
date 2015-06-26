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
        if let headerName = item as? String {
            let dict = headerName == "drawable" ? dataSource.drawables : dataSource.mipmaps
            //print(dict.count)
            return dict.count
        }
        //print(headers.count)
        return headers.count
    }
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let headerName = item as? String {
            let dict = headerName == "drawable" ? dataSource.drawables : dataSource.mipmaps
            let index = advance(dict.startIndex, index)
            //print(dict[index].0)
            return dict[index].0
        }
        return headers[index] as NSString
    }
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return outlineView.parentForItem(item) == nil
    }
    
    
//    /* View Based OutlineView: This method is not applicable.
//    */
//    func outlineView(outlineView: NSOutlineView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) {
//        
//    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        guard let key = item as? String else {
            let row = outlineView.rowForItem(item)
            let cell = outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as! NSTableCellView
            cell.textField?.stringValue = headers[row > 0 ? 1 : 0]
            return cell
        }
        guard let headerName = outlineView.parentForItem(item) as? String else {
            let cell = outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as! NSTableCellView
            cell.textField?.stringValue = key
            return cell
        }
        
        let dict = headerName == "drawable" ? dataSource.drawables : dataSource.mipmaps
        guard let datas = dict[key] else {
            return nil
        }
        
        //print("\(datas[0].name) § \(datas.count)\u{20DD}")
        let path = datas[0].file.fullPath
        let cell = outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
        cell.textField?.stringValue = "\(datas[0].name) § \(datas.count)\u{20DD}"
        cell.textField?.delegate = self
        cell.imageView?.image = NSImage(contentsOfFile: path)
        return cell
    }
    
    func outlineView(outlineView: NSOutlineView, shouldEditTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> Bool {
        return outlineView.parentForItem(item) != nil
    }
    
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
        return outlineView.parentForItem(item) == nil
    }
    
//    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
//        return outlineView.parentForItem(item) != nil
//    }
    
    // 编辑
    func outlineView(outlineView: NSOutlineView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) {
        print("object:\(object) item:\(item)")
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
