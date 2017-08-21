//
//  PageInfoMock.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/22.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

@testable import FluxCapacitorSample
import GithubKit

extension PageInfo {
    static func mock() -> PageInfo {
        return try! PageInfo(json: [
            "hasNextPage" : true,
            "hasPreviousPage" : false
            ])
    }
}
