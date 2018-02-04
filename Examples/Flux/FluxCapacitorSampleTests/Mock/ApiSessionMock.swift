//
//  ApiSessionMock.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/22.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import RxSwift
import GithubKit

@testable import FluxCapacitorSample

class ApiSessionMock: ApiSessionType {
    enum Error: Swift.Error {
        case requestFailed
    }

    class SessionTaskMock: URLSessionTask {
        override func resume() {}
        override func cancel() {}
    }

    var result: ApiSession.Result<Any>?

    func send<T: Request>(_ request: T, completion: @escaping (ApiSession.Result<T.ResponseType>) -> ()) -> URLSessionTask {
        switch result {
        case .success(let value as T.ResponseType)?:
            completion(.success(value))
        default:
            completion(.failure(Error.requestFailed))
        }
        return SessionTaskMock()
    }

    func send<T: Request>(_ request: T) -> Observable<T.ResponseType> {
        switch result {
        case .success(let value as T.ResponseType)?:
            return .just(value)
        default:
            return .error(Error.requestFailed)
        }
    }
}
