//
//  UIKeyboardWillShow.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import NoticeObserveKit

extension Notice.Names {
    static let keyboardWillShow = Notice.Name<UIKeyboardInfo>(UIResponder.keyboardWillShowNotification)
}
