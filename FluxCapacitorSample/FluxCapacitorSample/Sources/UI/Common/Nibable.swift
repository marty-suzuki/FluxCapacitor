//
//  Nibable.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit

protocol Nibable: NSObjectProtocol {}

extension Nibable {
    static var nib: UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
}
