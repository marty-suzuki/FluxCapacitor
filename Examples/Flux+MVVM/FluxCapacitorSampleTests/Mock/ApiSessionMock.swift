//
//  ApiSessionMock.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/22.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

@testable import FluxCapacitorSample
import RxSwift
import GithubKit

class ApiSessionMock: ApiSessionType {
    enum Error: Swift.Error {
        case requestFailed
    }
    
    var result: ApiSession.Result<Any>?
    
    func send<T: Request>(_ request: T, completion: @escaping (ApiSession.Result<Response<T.ResponseType>>) -> ()) -> URLSessionTask {
        switch result {
        case .success(let value as Response<T.ResponseType>)?:
            completion(.success(value))
        default:
            completion(.failure(Error.requestFailed))
        }
        return URLSessionTask()
    }
    
    func send<T: Request>(_ request: T) -> Observable<Response<T.ResponseType>> {
        switch result {
        case .success(let value as Response<T.ResponseType>)?:
            return .just(value)
        default:
            return .error(Error.requestFailed)
        }
    }
}
