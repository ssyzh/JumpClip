//
//  AppDelegate.swift
//  JumpClip
//
//  Created by 灏 孙  on 2018/11/14.
//  Copyright © 2018 灏 孙 . All rights reserved.
//

import Cocoa
import Magnet
import Carbon


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var statusItem: NSStatusItem = {
        let item = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
        let image = NSImage(named: NSImage.Name("StatusItemIcon"))
        image?.isTemplate = false
        item.button?.image = image
        return item
    }()
    
    lazy var bezel: BezelWC = {
        
        let windowController = NSStoryboard.init(name: NSStoryboard.Name.init("Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier.init("BezelWC")) as! BezelWC
        return windowController
    }()
    
    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.target = self
        statusItem.button?.action = #selector(showPopo(_:))
        
        if let keyCombo = KeyCombo(keyCode: kVK_ANSI_V, cocoaModifiers: [.control, .option]) {
            let hotKey = HotKey(identifier: "CommandOptionV", keyCombo: keyCombo) { hotKey in
                
                NSApp.activate(ignoringOtherApps: true)
                self.bezel.window?.makeKeyAndOrderFront(self)

            }
            hotKey.register()
        }
        
        
        
       
    }

    func applicationWillResignActive(_ notification: Notification) {
        
        NSApp.hide(self)
//    self.bezel.window?.orderOut(nil)
        
    }


}

extension AppDelegate{
    @objc func showPopo(_ btn:NSStatusBarButton){
        print("ssss")
    }
}

