//
//  BezelContentVC.swift
//  JumpClip
//
//  Created by 灏 孙  on 2018/11/15.
//  Copyright © 2018 灏 孙 . All rights reserved.
//

import Cocoa
import Carbon
import RxSwift
import RxCocoa
import RealmSwift
import Quartz

class BezelContentVC: NSViewController,NSTableViewDelegate,NSTableViewDataSource {

    @IBOutlet weak var table: NSTableView!
    @IBOutlet weak var detailInfo: NSTextField!
    
    var selectIndex:Int = 0
    var selectPage:Int = 0
    
    var contentsArray = [ClipModel]()
    lazy var jcPasteboard: NSPasteboard = {
        let pb = NSPasteboard.general
        return pb
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor(white: 0.0, alpha: 0.9).cgColor
        self.view.layer?.cornerRadius = 20.0
        
        
        self.table.rowSizeStyle = .custom
        
        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: Constan.notifacation_appShow), object: nil).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notification) in
            if let se = self {
                se.selectPage = 0
                se.selectIndex = 0
                se.selectClipModels(page: se.selectPage)
                se.table.reloadData()
                se.table.selectRowIndexes(IndexSet(integer:0), byExtendingSelection: false)
            }
            
        })
        
        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: Constan.notifacation_appHidden), object: nil).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notification) in
            if let se = self {
                print(se.table.selectedRow)
                let mo = se.contentsArray[se.table.selectedRow]
                se.jcPasteboard.declareTypes([.string], owner: nil)
                se.jcPasteboard.setString(mo.content!, forType: .string)
                
                let app = NSApplication.shared.delegate as! AppDelegate
                app.currentChangeCount = se.jcPasteboard.changeCount
                DispatchQueue.main.async {
                    let source = CGEventSource(stateID: .combinedSessionState)
                    // Disable local keyboard events while pasting
                    source?.setLocalEventsFilterDuringSuppressionState([.permitLocalMouseEvents, .permitSystemDefinedEvents], state: .eventSuppressionStateSuppressionInterval)
                    // Press Command + V
                    let keyVDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: true)
                    keyVDown?.flags = .maskCommand
                    // Release Command + V
                    let keyVUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: false)
                    keyVUp?.flags = .maskCommand
                    // Post Paste Command
                    keyVDown?.post(tap: .cgAnnotatedSessionEventTap)
                    keyVUp?.post(tap: .cgAnnotatedSessionEventTap)
                }
            }
            
        })
        
        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: Constan.notifacation_number), object: nil).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notification) in
            if let num = notification.userInfo!["number"] {
                self?.table.selectRowIndexes(IndexSet(integer: num as! IndexSet.Element), byExtendingSelection: false)
            }
  
        })
        
        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: Constan.notifacation_upArrow), object: nil).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notification) in
            if let row = self?.table.selectedRow {
                self?.table.selectRowIndexes(IndexSet(integer: row - 1), byExtendingSelection: false)
                
            }
            
        })
        
        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: Constan.notifacation_downArrow), object: nil).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notification) in
            if let row = self?.table.selectedRow {
                self?.table.selectRowIndexes(IndexSet(integer: row + 1), byExtendingSelection: false)
            }
        })
        
        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: Constan.notifacation_leftArrow), object: nil).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notification) in
            if let se = self {
                let page = se.selectPage - 1
                if page >= 0 {
                    se.selectPage = page
                    se.selectClipModels(page: page)
                    se.table.reloadData()
                    se.table.selectRowIndexes(IndexSet(integer:0), byExtendingSelection: false)

                }
            }
            
        })
        
        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: Constan.notifacation_rightArrow), object: nil).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notification) in
            if let se = self {
                if se.contentsArray.count == 10 {
                    let page = se.selectPage + 1
                    se.selectPage = page
                    se.selectClipModels(page: page)
                    se.table.reloadData()
                    se.table.selectRowIndexes(IndexSet(integer:0), byExtendingSelection: false)

                }
            }
        })

    }

}
extension BezelContentVC {
    func selectClipModels(page:Int){
//        let mo = ClipModel()
//        mo.content  = "sss"
//        contentsArray.append(mo)
        
        print(page)
        let mos = Array(try! Realm().objects(ClipModel.self).reversed())
        if mos.count > page * 10 {
            contentsArray.removeAll()
            for i in 0..<10 {
                let number = page * 10 + i
                if number < mos.count {
                    contentsArray.append(mos[number])
                }
            }
        }
    }
}
extension BezelContentVC{

    func numberOfRows(in tableView: NSTableView) -> Int {
 
        return contentsArray.count;
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HistoryCell"), owner: self) as! HistoryCell
        
        cell.textLab.stringValue = contentsArray[row].content ?? ""
        if let sourceBundleURL = contentsArray[row].sourceBundleURL {
            cell.iconImageView.image = NSWorkspace.shared.icon(forFile:sourceBundleURL)
        }
        return cell
    }
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 38.0
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        detailInfo.stringValue = contentsArray[table.selectedRow].content ?? ""

    }
    
}

extension BezelContentVC {

}

class HistoryCell:NSTableCellView {
    @IBOutlet weak var textLab: NSTextField!
    
    @IBOutlet weak var iconImageView: NSImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
