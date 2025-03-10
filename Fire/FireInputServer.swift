//
//  FireInputServer.swift
//  Fire
//
//  Created by marchyang on 2022/7/13.
//  Copyright © 2022 qwertyyb. All rights reserved.
//

import Foundation
import Defaults

private var previousClientIdentifier: String = ""
private var inputModeCache: [String: InputMode] = [:]

extension FireInputController {
    /**
    * 根据当前输入的应用改变输入模式
    */
    private func activeCurrentClientInputMode() {
        guard let identifier = client()?.bundleIdentifier() else { return }
        if let appSetting = Defaults[.appSettings][identifier],
         let mode = InputMode(rawValue: appSetting.inputModeSetting.rawValue) {
            print("[FireInputController] activeClientInputMode from setting : \(identifier), \(mode)")
            Fire.shared.toggleInputMode(mode)
            return
        }
        // 启用APP缓存设置
        if Defaults[.keepAppInputMode], let mode = inputModeCache[identifier] {
          print("[FireInputController] activeClientInputMode from cache: \(identifier), \(mode)")
          Fire.shared.toggleInputMode(mode)
      }
    }

    private func savePreviousClientInputMode() {
        if previousClientIdentifier.count > 0 {
            // 缓存当前输入模式
            inputModeCache.updateValue(inputMode, forKey: previousClientIdentifier)
        }
    }

    func clearEventListener() {
        temp.monitorList.forEach { (monitor) in
          if let m = monitor {
              NSEvent.removeMonitor(m)
          }
        }
        temp.observerList.forEach { (observer) in
          NotificationCenter.default.removeObserver(observer)
        }
        temp.monitorList = []
        temp.observerList = []
    }
    func previousClientHandler() {
        clean()
        clearEventListener()
        savePreviousClientInputMode()
    }

    /**
    * 1.  由于使用recognizedEvents在一些场景下不能监听到flagChanged事件，比如保存文件场景
    *      所以这里需要使用NSEvent.addGlobalMonitorForEvents监听shift键被按下
    *  2. 当client变化时，deactiveServer 和 activeServer 的执行是不固定的，有可能 activeServer 先执行，所以需要在activeServer中执行清理逻辑
    */
    override func activateServer(_ sender: Any!) {
        NSLog("[FireInputController] activate server: \(client()?.bundleIdentifier() ?? sender.debugDescription)")

        previousClientHandler()

        if let identifier = client()?.bundleIdentifier() {
            previousClientIdentifier = identifier
        }

        // 监听candidateView点击，翻页事件
        notificationList().forEach { (observer) in temp.observerList.append(NotificationCenter.default.addObserver(
          forName: observer.name, object: nil, queue: nil, using: observer.callback
        ))}
        if Defaults[.disableEnMode] {
          Fire.shared.toggleInputMode(.zhhans)
          return
        }

        activeCurrentClientInputMode()
        temp.monitorList.append(NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { (event) in
          if !InputSource.shared.isSelected() {
              return self.clearEventListener()
          }
          _ = self.handle(event, client: self.client())
        })
    }
    override func deactivateServer(_ sender: Any!) {
        NSLog("[FireInputController] deactivate server: \(client()?.bundleIdentifier() ?? "no client deactivate")")
    }
}
