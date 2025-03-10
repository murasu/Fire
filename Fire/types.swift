//
//  types.swift
//  Fire
//
//  Created by 虚幻 on 2020/10/25.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import Foundation
import Defaults
import Sparkle
import SwiftUI

enum CandidatesDirection: Int, Decodable, Encodable {
    case vertical
    case horizontal
}

enum InputModeTipWindowType: Int, Decodable, Encodable {
    case followInput
    case centerScreen
    case none
}

enum ModifierKey: String, Codable {
  case shift
  case leftShift
  case rightShift
  case control
  case command
  case option
  case function
}

class ApplicationSettingItem: ObservableObject, Codable, Identifiable {
//    let identifier: String = ""

    @Published var bundleIdentifier: String = ""

    @Published var inputModeSetting: InputModeSetting = InputModeSetting.recentUsed {
        didSet {
            self.objectWillChange.send()
        }
    }

    var createdTimestamp: Int = 0

    private enum CodingKeys: String, CodingKey {
        case bundleIdentifier
        case inputModeSetting
        case createdTimestamp
    }

    init(bundleId: String, inputMs: InputModeSetting) {
        bundleIdentifier = bundleId
        inputModeSetting = inputMs
        createdTimestamp = Int(Date().timeIntervalSince1970)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        bundleIdentifier = try values.decode(String.self, forKey: .bundleIdentifier)
        inputModeSetting = try values.decode(InputModeSetting.self, forKey: .inputModeSetting)
        createdTimestamp = try values.decode(Int.self, forKey: .createdTimestamp)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bundleIdentifier, forKey: .bundleIdentifier)
        try container.encode(inputModeSetting, forKey: .inputModeSetting)
        try container.encode(createdTimestamp, forKey: .createdTimestamp)
    }
}

enum PunctuationMode: Codable {
    case enUs // 半角
    case zhhans // 全角
    case custom // 自定义
}

extension Defaults.Keys {
    static let zKeyQuery = Key<Bool>("zKeyQuery", default: true)
    static let candidatesDirection = Key<CandidatesDirection>(
        "candidatesDirection",
        default: CandidatesDirection.horizontal
    )
    static let showCodeInWindow = Key<Bool>("showCodeInWindow", default: true)
    static let wubiCodeTip = Key<Bool>("wubiCodeTip", default: true)
    static let wubiAutoCommit = Key<Bool>("wubiAutoCommit", default: false)
    static let candidateCount = Key<Int>("candidateCount", default: 5)
    static let codeMode = Key<CodeMode>("codeMode", default: CodeMode.wubiPinyin)

    // 中英文切换配置
    // 禁止切换英文
    static let disableEnMode = Key<Bool>("diableEnMode", default: false)
    // 切换英文模式的按键
    static let toggleInputModeKey = Key<ModifierKey>("toggleInputModeKey", default: ModifierKey.shift)
    // 中英文切换提示弹窗位置
    static let inputModeTipWindowType = Key<InputModeTipWindowType>(
        "inputModeTipWindowType",
        default: InputModeTipWindowType.centerScreen
    )
    static let showInputModeStatus = Key<Bool>("showInputModeStatus", default: true)

    // 主题
    static let themeConfig = Key<ThemeConfig>("themeConfig", default: defaultThemeConfig)
    static let importedThemeConfig = Key<ThemeConfig?>("importedThemeConfig", default: nil)

    // 应用输入配置
    static let keepAppInputMode = Key<Bool>("keepAppInputMode", default: true)
    static let appSettings = Key<[String: ApplicationSettingItem]>(
        "AppSettings",
        default: [:]
    )
    // 标点符号配置
    static let punctuationMode = Key<PunctuationMode>("punctuationMode", default: PunctuationMode.zhhans)
    static let customPunctuationSettings = Key<[String: String]>("customPunctuationSettings", default: punctuation)

    static let wbTablePath = Key<String>(
        "wbTableURL",
        default: Bundle.main.resourceURL?.appendingPathComponent("wb_table.txt").path
            ?? "")
    static let pyTablePath = Key<String>(
        "pyTableURL",
        default: Bundle.main.resourceURL?.appendingPathComponent("py_table.txt").path
            ?? "")

    // 统计配置
    static let enableStatistics = Key<Bool>("enableStatistics", default: true)
    //            ^            ^         ^                ^
    //           Key          Type   UserDefaults name   Default value
}

enum InputMode: String {
    case zhhans
    case enUS
}

enum InputModeSetting: String, Codable {
    case zhhans
    case enUS
    case recentUsed
}

enum CandidateType: String {
    case wb = "wb" // 五笔
    case py = "py" // 拼音
    case user = "user" // 用户词库
    case placeholder = "placeholder" // 运行时类型，无匹配时表示占位
}

struct Candidate: Hashable {
    let code: String
    let text: String
    let type: CandidateType
}

enum CodeMode: Int, CaseIterable, Decodable, Encodable {
    case wubi
    case pinyin
    case wubiPinyin
}

let punctuation: [String: String] = [
    ",": "，",
    ".": "。",
    "/": "、",
    ";": "；",
    "'": "‘",
    "[": "［",
    "]": "］",
    "`": "｀",
    "!": "！",
    "@": "‧",
    "#": "＃",
    "$": "￥",
    "%": "％",
    "^": "……",
    "&": "＆",
    "*": "×",
    "(": "（",
    ")": "）",
    "-": "－",
    "_": "——",
    "+": "＋",
    "=": "＝",
    "~": "～",
    "{": "｛",
    "\\": "、",
    "|": "｜",
    "}": "｝",
    ":": "：",
    "\"": "“",
    "<": "《",
    ">": "》",
    "?": "？"
]

protocol ToastWindowProtocol {
    func show(_ text: String, position: NSPoint)
}
