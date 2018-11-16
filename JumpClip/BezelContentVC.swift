//
//  BezelContentVC.swift
//  JumpClip
//
//  Created by 灏 孙  on 2018/11/15.
//  Copyright © 2018 灏 孙 . All rights reserved.
//

import Cocoa

class BezelContentVC: NSViewController,NSTableViewDelegate,NSTableViewDataSource {

    @IBOutlet weak var table: NSTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor(white: 0.1, alpha: 0.5).cgColor
        self.view.layer?.cornerRadius = 20.0
        
        NSEvent.addLocalMonitorForEvents(matching:[.flagsChanged,.keyUp,.keyDown]) { (even) -> NSEvent? in
            
            switch even.type {
            case .keyUp:
                print("松开")
            case .keyDown:
                print("按下")
            case .flagsChanged:
                print(even)
                
                NSApp.hide(self)
            
                
            default:
                print("其他")
                
            }
            print(even)
            
            return even
        }
        
    }
    
}

extension BezelContentVC{

    func numberOfRows(in tableView: NSTableView) -> Int {
        return 10;
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HistoryCell"), owner: self)
        
        return cell
    }
}

class HistoryCell:NSTableCellView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
