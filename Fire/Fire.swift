//
//  Fire.swift
//  Fire
//
//  Created by 虚幻 on 2019/9/15.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa
import InputMethodKit
import Sparkle
import Defaults

let kConnectionName = "Fire_1_Connection"

extension UserDefaults {
    @objc dynamic var codeMode: Int {
        get {
            return integer(forKey: "codeMode")
        }
        set {
            set(newValue, forKey: "codeMode")
        }
    }
}

internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

class Fire: NSObject {
    // SwiftUI 界面事件
    static let candidateSelected = Notification.Name("Fire.candidateSelected")
    static let candidateListUpdated = Notification.Name("Fire.candidateListUpdated")
    static let nextPageBtnTapped = Notification.Name("Fire.nextPageBtnTapped")
    static let prevPageBtnTapped = Notification.Name("Fire.prevPageBtnTapped")

    // 逻辑
    static let candidateInserted = Notification.Name("Fire.candidateInserted")
    static let inputModeChanged = Notification.Name("Fire.inputModeChanged")

    var inputMode: InputMode = .zhhans

    func transformPunctuation(_ origin: String)-> String? {
        let isPunctuation = punctuation.keys.contains(origin)
        if !isPunctuation {
            return nil
        }
        let mode = Defaults[.punctuationMode]
        if mode == .enUs {
            return origin
        }
        if mode == .zhhans {
            return punctuation[origin]
        }
        if mode == .custom {
            return Defaults[.customPunctuationSettings][origin]
        }
        return nil
    }

    func toggleInputMode(_ nextInputMode: InputMode? = nil) {
        if nextInputMode != nil, self.inputMode == nextInputMode {
            return
        }
        let oldVal = self.inputMode
        if let nextInputMode = nextInputMode, nextInputMode != self.inputMode {
            self.inputMode = nextInputMode
        } else {
            self.inputMode = inputMode == .enUS ? .zhhans : .enUS
        }
        NotificationCenter.default.post(name: Fire.inputModeChanged, object: nil, userInfo: [
            "oldVal": oldVal,
            "val": self.inputMode,
            "label": self.inputMode == .enUS ? "英" : "中"
        ])
    }

    var server: IMKServer = IMKServer.init(name: kConnectionName, bundleIdentifier: Bundle.main.bundleIdentifier)
    func getCandidates(origin: String = String(), page: Int = 1) -> (candidates: [Candidate], hasNext: Bool) {
        if origin.count <= 0 {
            return ([], false)
        }
        let (candidates, hasNext) = DictManager.shared.getCandidates(query: origin, page: page)
        let transformed = candidates.map { (candidate) -> Candidate in
            if candidate.type == .user {
                return Candidate(code: candidate.code, text: candidate.text, type: .user)
            }
            return candidate
        }
        return (transformed, hasNext)
    }

    static let shared = Fire()
}
