//
//  ValueNotifyCenter.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2018/02/04.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

final class ValueNotifyCenter<Element> {

    private struct Observer {
        fileprivate struct Token {
            let value = UUID().uuidString
        }

        fileprivate let token: Token
        fileprivate let excuteQueue: ExecuteQueue
        fileprivate let changes: (Element) -> ()
    }

    private var objects: [Observer] = []
    private let mutex = PThreadMutex()

    func addObserver(excuteQueue: ExecuteQueue, changes: @escaping (Element) -> Void) -> Dust {

        mutex.lock()
        let observer = Observer(token: .init(), excuteQueue: excuteQueue, changes: changes)
        objects.append(observer)
        let token = observer.token
        mutex.unlock()

        return Dust { [weak self] in
            guard let me = self else { return }
            defer { me.mutex.unlock() }; me.mutex.lock()
            me.objects = me.objects.filter { $0.token.value != token.value }
        }
    }

    func notifyChanges(value: Element) {
        objects.forEach { observer in
            let execute: () -> Void = {
                observer.changes(value)
            }

            switch observer.excuteQueue {
            case .current:
                execute()

            case .main:
                if Thread.isMainThread {
                    execute()
                } else {
                    DispatchQueue.main.async(execute: execute)
                }

            case .queue(let queue):
                queue.async(execute: execute)
            }
        }
    }
}
