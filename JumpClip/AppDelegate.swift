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
import RealmSwift
import RxCocoa
import RxSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var statusItem: NSStatusItem = {
        let item = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
        let image = NSImage(named: NSImage.Name("StatusItemIcon"))
        image?.isTemplate = false
        item.button?.image = image
        return item
    }()
    
    lazy var bezel: NSWindowController = {
        
        let windowController = NSStoryboard.init(name: NSStoryboard.Name.init("Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier.init("BezelWC")) as! NSWindowController
        return windowController
    }()
    
    lazy var jcPasteboard: NSPasteboard = {
       let pb = NSPasteboard.general
        return pb
    }()
    
    var isShow: Bool = false
    var pollPBTimer: Timer?
    var currentChangeCount: Int = 0
    final var currentContent: String = ""


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let opts = NSDictionary(object: kCFBooleanTrue,
                                forKey: kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
            ) as CFDictionary
        
        AXIsProcessTrustedWithOptions(opts)
   
        createStatusMenu()
        // 设置数据库文件名
        setDefaultRealmForUser(username: "test")
        setEvevtObserve()
        statusItem.button?.target = self
//        statusItem.button?.action = #selector(showPopo(_:))
        
        pollPBTimer = Timer.scheduledTimer(timeInterval: (0.5), target: self, selector: #selector(pollPB(_:)), userInfo: nil, repeats: true)
        
        
        if let keyCombo = KeyCombo(keyCode: kVK_ANSI_V, cocoaModifiers: [.control, .option]) {
            let hotKey = HotKey(identifier: "CommandOptionV", keyCombo: keyCombo) { [ weak self] (hotKey) in
                self?.showApp()

            }
            hotKey.register()
        }
        
        
        
        
        
       
    }

    func applicationWillResignActive(_ notification: Notification) {
        hiddenApp()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constan.notifacation_appHidden), object: nil, userInfo:nil)

    }


}
extension AppDelegate{
    func setDefaultRealmForUser(username: String) {
        var config = Realm.Configuration(shouldCompactOnLaunch: { totalBytes, usedBytes in
  
            let oneHundredMB = 30 * 1024 * 1024
            return (totalBytes > oneHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5
        })
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(username).realm")
        print(config.fileURL!.absoluteString)
        Realm.Configuration.defaultConfiguration = config
    }
    
    func setEvevtObserve() {
        NSEvent.addLocalMonitorForEvents(matching:[.flagsChanged,.keyUp,.keyDown]) { [weak self](even) -> NSEvent? in
            
            switch even.type {
            case .keyDown:
                let code = Int(even.keyCode)
                switch  code{
                case kVK_UpArrow :
                    print("上")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constan.notifacation_upArrow), object: nil, userInfo: ["number":index])

                case kVK_DownArrow:
                    print("下")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constan.notifacation_downArrow), object: nil, userInfo: ["number":index])

                case kVK_LeftArrow:
                    print("左")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constan.notifacation_leftArrow), object: nil, userInfo: ["number":index])

                case kVK_RightArrow:
                    print("右")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constan.notifacation_rightArrow), object: nil, userInfo: ["number":index])

                case kVK_ANSI_0, kVK_ANSI_1, kVK_ANSI_2, kVK_ANSI_3, kVK_ANSI_4, kVK_ANSI_5, kVK_ANSI_6, kVK_ANSI_7, kVK_ANSI_8, kVK_ANSI_9:
                    
                    let index = Constan.nuberKeyIndexs.firstIndex(of: code)!
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constan.notifacation_number), object: nil, userInfo: ["number":index])
              
                default:
                    print(even)
                }
                
            case .flagsChanged:
                self?.hiddenApp()
                
            default:
                break
                
            }
            
            return even
        }
    }
    
    fileprivate func createStatusMenu(){
        // 添加主菜单
        let mainMenu = NSMenu()
        
        // 1. 获取系统状态栏的StatusItem

        
//        // 添加关于子选项
//        let aboutItem = NSMenuItem(title: "About SimulatorFinder", action: #selector(MenuManager.showAbout), keyEquivalent: "")
//        aboutItem.target = self
//        mainMenu.addItem(aboutItem)
//        // 添加Preference 子项
//        let preferenceItem = NSMenuItem(title: "Preference...", action: #selector(MenuManager.showPreference), keyEquivalent: "")
//        mainMenu.addItem(preferenceItem)
//        preferenceItem.target = self
//        // 添加分隔
//        mainMenu.addItem(NSMenuItem.separator())
        
        // 添加退出项
        let exitItem = NSMenuItem(title: "退出", action: #selector(exitApp), keyEquivalent: "")
        mainMenu.addItem(exitItem)
        exitItem.target = self
        statusItem.menu = mainMenu
        
    }
    @objc func click()  {
        print("click statusItem ....")
    }
    
}
extension AppDelegate{

    func hiddenApp() {
        NSApp.hide(self)
        self.isShow = false
    }
    func showApp() {
        if !self.isShow {
            self.isShow = true
            NSApp.activate(ignoringOtherApps: true)
            self.bezel.window?.orderFrontRegardless()
            self.bezel.window?.center()
            self.bezel.showWindow(self)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constan.notifacation_appShow), object: nil, userInfo:nil)

        }
    }
    
    @objc func pollPB(_ timer:Timer){
        
        guard jcPasteboard.changeCount > currentChangeCount else{
            return;
        }
        guard jcPasteboard.types != nil else {
            print("return == nil")
            return
        }
  
        
        currentChangeCount = jcPasteboard.changeCount
        if  let content = jcPasteboard.string(forType: .string) {
            var currentApp: NSRunningApplication?
            for run in NSWorkspace.shared.runningApplications{
                if run.isActive {
                    currentApp = run
                    break
                }
            }
            guard currentContent != content else{
                return;
            }
            let mo = ClipModel()
            mo.content = content
            mo.changeCount = jcPasteboard.changeCount
            mo.sourceName = currentApp?.localizedName
            mo.sourceBundleURL = currentApp?.bundleURL?.path
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(mo)
            }
            currentContent = content
        }
        
    }
    @objc fileprivate func exitApp(){
        print("exit. app")
        NSApp.terminate(self)
    }
}

