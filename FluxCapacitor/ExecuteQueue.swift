//
//  ExecuteQueue.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2018/02/02.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

public enum ExecuteQueue {
    case current
    case main
    case queue(DispatchQueue)
}
