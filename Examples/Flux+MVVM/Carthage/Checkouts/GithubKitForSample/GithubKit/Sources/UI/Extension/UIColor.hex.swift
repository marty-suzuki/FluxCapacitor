//
//  UIColor.hex.swift
//  GithubKitForSample
//
//  Created by marty-suzuki on 2017/08/05.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init?(hexString: String) {
        let hexString = hexString.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexString)
        scanner.scanLocation = 0
        var color: UInt64 = 0
        if scanner.scanHexInt64(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0xFF00) >> 8) / 255.0
            let b = CGFloat(color & 0xFF) / 255.0
            self.init(red: r, green: g, blue: b, alpha: 1)
            return
        }
        return nil
    }
}
