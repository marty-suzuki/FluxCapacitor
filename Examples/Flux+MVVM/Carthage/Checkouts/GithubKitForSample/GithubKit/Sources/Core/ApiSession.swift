//
//  ApiSession.swift
//  GithubApiSession
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import RxSwift

public final class ApiSession {
    public enum Result<T> {
        case success(T)
        case failure(Swift.Error)
    }

    public enum Error: Swift.Error {
        case emptyData
        case emptyToken
        case generateBaseURLFaild
    }
    
    private class EmptySessionTask: URLSessionTask {
        override init() {
            super.init()
        }
        
        override func cancel() {}
        override func resume() {}
        override func suspend() {}
    }

    private let session: URLSession
    private let configuration: URLSessionConfiguration
    private let injectToken: () -> InjectableToken

    public init(injectToken: @escaping () -> InjectableToken,
                configuration: URLSessionConfiguration = .default) {
        configuration.timeoutIntervalForRequest = 30
        self.configuration = configuration
        self.session = URLSession(configuration: configuration)
        self.injectToken = injectToken
    }

    public func send<T: Request>(_ request: T, completion: @escaping (Result<T.ResponseType>) -> ()) -> URLSessionTask {

        let injectableToken: InjectableToken_<Ready>
        let injectableBaseURL: InjectableBaseURL
        do {
            injectableToken = try injectToken().readify()
            injectableBaseURL = try InjectableBaseURL(string: "https://api.github.com/graphql")
        } catch let e {
            completion(.failure(e))
            return EmptySessionTask()
        }

        let proxy = RequestProxy(request: request, injectableBaseURL: injectableBaseURL, injectableToken: injectableToken)
        let urlRequest = proxy.buildURLRequest()
        let task = session.dataTask(with: urlRequest) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(Error.emptyData))
                return
            }
            do {
                try completion(.success(T.decode(with: data)))
            } catch let e {
                completion(.failure(e))
            }
        }
        task.resume()
        return task
    }
}

extension ApiSession: ReactiveCompatible {}

extension Reactive where Base == ApiSession {
    public func send<T: Request>(_ request: T) -> Observable<T.ResponseType> {
        return Single<T.ResponseType>.create { [weak session = base] observer in
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
