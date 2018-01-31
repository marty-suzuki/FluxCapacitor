//
//  Nibable.swift
//  GithubKitForSample
//
//  Created by marty-suzuki on 2017/08/05.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit

public protocol Nibable: ReusableViewProtocol {
    static func makeFromNib() -> Self
}

extension Nibable where RegisterType == RegisterNib {
    public static func makeFromNib() -> Self {
        return nib!.instantiate(withOwner: nil, options: nil).first as! Self
    }
}
