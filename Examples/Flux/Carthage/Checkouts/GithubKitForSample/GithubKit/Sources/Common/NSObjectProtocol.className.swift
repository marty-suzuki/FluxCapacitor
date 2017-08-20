//
//  NSObjectProtocol.className.swift
//  GithubKitForSample
//
//  Created by marty-suzuki on 2017/08/05.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

extension NSObjectProtocol {
    public static var className: String {
        return String(describing: Self.self)
    }
}
