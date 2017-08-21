//
//  ResponseMock.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/22.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

@testable import FluxCapacitorSample
import GithubKit

extension Response {
    init(nodes: [T], pageInfo: PageInfo, totalCount: Int) {
        self.nodes = nodes
        self.pageInfo = pageInfo
        self.totalCount = totalCount
    }
}
