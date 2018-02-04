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
    static func mock(hasNextPage: Bool = true,
                     hasPreviousPage: Bool = false,
                     startCursor: String? = nil,
                     endCursor: String? = nil) -> PageInfo {
        var json: [AnyHashable : Any] = [
            "hasNextPage" : hasNextPage,
            "hasPreviousPage" : hasPreviousPage
        ]
        if let startCursor = startCursor {
            json["startCursor"] = startCursor
        }
        if let endCursor = endCursor {
            json["endCursor"] = endCursor
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return try JSONDecoder().decode(PageInfo.self, from: data)
        } catch let e {
            fatalError(e.localizedDescription)
        }
    }
}
