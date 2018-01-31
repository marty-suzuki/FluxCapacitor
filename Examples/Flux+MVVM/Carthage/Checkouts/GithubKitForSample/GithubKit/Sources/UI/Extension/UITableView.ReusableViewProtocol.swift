//
//  UITableView.ReusableViewProtocol.swift
//  GithubKitForSample
//
//  Created by marty-suzuki on 2017/08/05.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit

extension UITableView {
    public typealias ReusableCell = ReusableViewProtocol & UITableViewCell
    public typealias ReusableView = ReusableViewProtocol & UITableViewHeaderFooterView
    
    public func registerDefaultCell() {
        register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
    }
    
    public func register<T: ReusableCell>(_ cell: T.Type) {
        register(T.nib, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    public func register<T: ReusableView>(_ view: T.Type) {
        register(T.nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }
    
    public func dequeueReusableDefaultCell(for indexPath: IndexPath) -> UITableViewCell {
        return dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
    }
    
    public func dequeue<T: ReusableCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
    
    public func dequeue<T: ReusableView>(_ type: T.Type) -> T {
        return dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as! T
    }
}
