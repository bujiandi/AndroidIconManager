//
//  ImageController.swift
//  AndroidIconManager
//
//  Created by 慧趣小歪 on 15/6/25.
//  Copyright © 2015年 慧趣小歪. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    weak var sideController: SideController!

    @IBOutlet weak var tableView: NSTableView!
    
    var dataSource:ImageDataSource { return ImageDataSource.shared }

    var selectionKeys:[String] = []
    
    func reloadData(keys:[String]) {
        
        selectionKeys = keys
        
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        print(selectionKeys.count)
        if item != nil { return 0 }
        return selectionKeys.count
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        return selectionKeys[index]
    }
    
//    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
//        print(item)
//        return nil
//    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return false
    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        let cell = outlineView.makeViewWithIdentifier("DataCell", owner: self) as! ImagesCellView
        cell.textField?.stringValue = item as? String ?? ""
        return cell
    }
    
}
