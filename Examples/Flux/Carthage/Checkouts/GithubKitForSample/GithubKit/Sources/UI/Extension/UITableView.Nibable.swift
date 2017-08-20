//
//  UITableView.Nibable.swift
//  GithubKitForSample
//
//  Created by marty-suzuki on 2017/08/05.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit

extension UITableView {
    public func registerDefaultCell() {
        register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
    }
    
    public func registerCell<T: Nibable>(_ cell: T.Type) {
        register(T.nib, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    public func registerHeaderFooterView<T: Nibable>(_ view: T.Type) {
        register(T.nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }
    
    public func dequeueReusableDefaultCell(for indexPath: IndexPath) -> UITableViewCell {
        return dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
    }
    
    public func dequeueReusableCell<T: UITableViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T where T: Nibable {
        return dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
    
    public func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ type: T.Type) -> T where T: Nibable {
        return dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as! T
    }
}
