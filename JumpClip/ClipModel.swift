//
//  ClipModel.swift
//  JumpClip
//
//  Created by 灏 孙  on 2018/11/21.
//  Copyright © 2018 灏 孙 . All rights reserved.
//

import Foundation
import RealmSwift


class ClipModel: Object {
//    @objc dynamic var id = 0
    @objc dynamic var changeCount: Int = 0
    @objc dynamic var content: String? = nil
    @objc dynamic var sourceName: String? = nil
    @objc dynamic var sourceBundleURL: String? = nil
//    override static func primaryKey() -> String? {
//        return "id"
//    }
}
