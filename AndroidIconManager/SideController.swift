//
//  SiderController.swift
//  AndroidIconManager
//
//  Created by 慧趣小歪 on 15/6/25.
//  Copyright © 2015年 慧趣小歪. All rights reserved.
//

import Cocoa
import Util

class SideController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {

    var drawables:[[File]] = []
    var mipmaps:[[File]] = []
    var headers:[String] = ["drawable","mipmap"]

    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.parentViewController
    }
    
    func showSuccess() {
        print("success Side")
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
            return dict.count
        }
        return headers.count
    }
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let headerName = item as? String {
            let dict = headerName == "drawable" ? dataSource.drawables : dataSource.mipmaps
            return dict.values.array[index]
        }
        return headers[index]
    }
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return item is String
    }
    
    
//    /* View Based OutlineView: This method is not applicable.
//    */
//    func outlineView(outlineView: NSOutlineView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) {
//        
//    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        if let headerName = item as? String {
            let cell = outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as! NSTableCellView
            cell.textField?.stringValue = headerName
            return cell
        }
        let datas = item as! [ImageItem]
        let path = datas[0].file.fullPath
        let cell = outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
        cell.textField?.stringValue = datas[0].name
        cell.imageView?.image = NSImage(contentsOfFile: path)
        return cell
    }
}
