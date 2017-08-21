//
//  ApiSessionType.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/21.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import GithubKit
import RxSwift

protocol ApiSessionType {
    func send<T: Request>(_ request: T, completion: @escaping (ApiSession.Result<Response<T.ResponseType>>) -> ()) -> URLSessionTask
    func send<T: Request>(_ request: T) -> Observable<Response<T.ResponseType>>
}

extension ApiSession: ApiSessionType {
    func send<T: Request>(_ request: T) -> Observable<Response<T.ResponseType>> {
        return rx.send(request)
    }
}
