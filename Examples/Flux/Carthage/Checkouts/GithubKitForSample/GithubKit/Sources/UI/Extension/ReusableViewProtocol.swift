//
//  ReusableViewProtocol.swift
//  GithubKit
//
//  Created by marty-suzuki on 2017/12/05.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit

public protocol ReusableViewRegisterType {}
public enum RegisterNib: ReusableViewRegisterType {}
public enum RegisterClass: ReusableViewRegisterType {}

public protocol ReusableViewProtocol: NSObjectProtocol {
    associatedtype RegisterType: ReusableViewRegisterType
    static var reuseIdentifier: String { get }
    static var nib: UINib? { get }
}

extension ReusableViewProtocol {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension ReusableViewProtocol where RegisterType == RegisterNib {
    public static var nib: UINib? {
        return UINib(nibName: reuseIdentifier, bundle: Bundle(for: self))
    }
}

extension ReusableViewProtocol where RegisterType == RegisterClass {
    public static var nib: UINib? {
        return nil
    }
}
