//
//  Int.truncateString.swift
//  GithubKitForSample
//
//  Created by marty-suzuki on 2017/08/05.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

extension Int {
    var truncateString: String {
        switch self {
        case 0...999:
            return "\(self)"
        case 1000...999999:
            return "\(String(format: "%.1f", Double(self) / 1000))K"
        default:
            return "\(String(format: "%.1f", Double(self) / 1000000))K"
        }
    }
}
