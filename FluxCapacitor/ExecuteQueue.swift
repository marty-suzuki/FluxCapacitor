//
//  ExecuteQueue.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2018/02/02.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

/// Represents execution queue.
public enum ExecuteQueue {
    /// Processing continues on the running thread.
    case current

    /// If running thread is main, processing executes with sync.
    /// If running thread is not main, processing executes with async.
    case main

    /// It execute with async.
    case queue(DispatchQueue)
}
