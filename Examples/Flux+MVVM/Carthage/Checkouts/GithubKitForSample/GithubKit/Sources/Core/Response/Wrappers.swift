//
//  Wrappers.swift
//  GithubApiSession
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

func _valueNotFound<T>(codingPath: [CodingKey], debugDescription: String) throws -> T {
    let context = DecodingError.Context(codingPath: codingPath, debugDescription: debugDescription)
    throw DecodingError.valueNotFound(T.self, context)
}

struct ISO8601DateWrapper {
    let value: Date
}

extension ISO8601DateWrapper: Swift.Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try DateFormatter.ISO8601.date(from: container.decode(String.self))
            ?? _valueNotFound(codingPath: [], debugDescription: "can not convert to Date")
    }
}

struct TotalCountWrapper {
    let value: Int
}

extension TotalCountWrapper: Swift.Decodable {
    private enum CodingKeys: String, CodingKey {
        case totalCount
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decode(Int.self, forKey: .totalCount)
    }
}
