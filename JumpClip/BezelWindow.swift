//
//  BezelWindow.swift
//  JumpClip
//
//  Created by 灏 孙  on 2018/11/14.
//  Copyright © 2018 灏 孙 . All rights reserved.
//

import Cocoa

class BezelWindow: NSWindow {

    override func awakeFromNib() {
        self.backgroundColor = NSColor.clear
        self.level = .screenSaver
        if let mainSize = NSScreen.main?.frame.size {
            
            let wi:CGFloat = mainSize.width / 2
            let hi:CGFloat = mainSize.height / 2
            self.setFrame(NSRect(x: (mainSize.width - wi)/2.0, y: (mainSize.height - hi)/2.0, width: wi, height: hi), display: true)
        }
    }
    override var acceptsFirstResponder: Bool{
        return true
    }
    override var isKeyWindow: Bool {
        return true
    }
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        print("Equivalent")
        return true
    }
    
    override func keyUp(with event: NSEvent) {
        print("up")
    }
    override func keyDown(with event: NSEvent) {
        print("down")
    }
}
