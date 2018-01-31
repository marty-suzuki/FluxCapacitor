//
//  Response.swift
//  GithubApiSession
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

public protocol ResponseDecodable: Decodable {}

public struct Response<T: JSONDecodable>: ResponseDecodable {
    public let nodes: [T]
    public let pageInfo: PageInfo
    public let totalCount: Int
}

extension Response {
    private typealias ResponseDecoder = T.ResponseDecoder

    public init(from decoder: Decoder) throws {
        let containers = try ResponseDecoder.containers(from: decoder)
        self.nodes = try containers.common.decode([T].self, forKey: .nodes)
        self.pageInfo = try containers.common.decode(PageInfo.self, forKey: .pageInfo)
        self.totalCount = try containers.count.decode(Int.self, forKey: ResponseDecoder.totalCount)
    }
}

public enum ResponseCodingKeys: String, CodingKey {
    case nodes
    case pageInfo
}

public typealias CommonContainer = KeyedDecodingContainer<ResponseCodingKeys>
public typealias CountContainer = KeyedDecodingContainer<TotalCountCodingKey>

public protocol ResponseDecoderProtocol {
    static var totalCount: TotalCountCodingKey { get }
    static func containers(from decoder: Decoder) throws -> (common: CommonContainer, count: CountContainer)
}

public protocol JSONDecodable: Decodable {
    associatedtype ResponseDecoder: ResponseDecoderProtocol
}

public struct TotalCountCodingKey: CodingKey {
    public let stringValue: String
    public let intValue: Int?

    init(_ key: String) {
        self.stringValue = key
        self.intValue = nil
    }

    public init?(stringValue: String) {
        fatalError("use init(_:)")
    }

    public init?(intValue: Int) {
        fatalError("use init(_:)")
    }
}
