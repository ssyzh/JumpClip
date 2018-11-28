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
            let he:CGFloat = 460
//            self.setFrame(NSRect(x: (mainSize.width - wi)/2.0, y: (mainSize.height - he)/2.0, width: wi, height: he), display: true)
            self.setContentSize(NSSize(width: wi, height: he))
        }
    }

}
