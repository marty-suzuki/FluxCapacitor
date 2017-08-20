//
//  UILabel.Octicons.swift
//  GithubKitForSample
//
//  Created by marty-suzuki on 2017/08/05.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import SwiftIconFont

extension UILabel {
    enum OcticonIcon: String {
        case repo = "repo"
        case repoFork = "repo-forked"
        case star = "star"
        case location = "location"
        case eye = "eye"
        case organization = "organization"
    }
    
    func setText(as icon: OcticonIcon, ofSize size: CGFloat = 16) {
        font = .icon(from: .Octicon, ofSize: size)
        text = .fontOcticon(icon.rawValue)
    }
}
