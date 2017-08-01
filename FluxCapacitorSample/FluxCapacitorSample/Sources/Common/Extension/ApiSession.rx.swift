//
//  ApiSession.rx.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import RxSwift
import GithubApiSession

extension ApiSession: ReactiveCompatible {}

extension Reactive where Base == ApiSession {
    func send<T: Request>(_ request: T) -> Observable<Response<T.ResponseType>> {
        return Single<Response<T.ResponseType>>.create { [weak session = base] observer in
            guard let session = session else {
                return Disposables.create()
            }
            let task = session.send(request) {
                switch $0 {
                case .success(let value):
                    observer(.success(value))
                case .failure(let error):
                    observer(.error(error))
                }
            }
            return Disposables.create {
                task.cancel()
            }
        }.asObservable()
    }
}
