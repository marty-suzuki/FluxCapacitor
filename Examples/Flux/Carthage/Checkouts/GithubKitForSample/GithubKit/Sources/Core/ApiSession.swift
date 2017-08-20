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
    }

    public static let shared = ApiSession()

    private let session: URLSession
    private let configuration: URLSessionConfiguration
    
    public var token: String? {
        set { RequestConfig.shared.token = newValue }
        get { return RequestConfig.shared.token }
    }

    public init(configuration: URLSessionConfiguration = .default) {
        configuration.timeoutIntervalForRequest = 30
        self.configuration = configuration
        self.session = URLSession(configuration: configuration)
    }

    public func send<T: Request>(_ request: T, completion: @escaping (Result<Response<T.ResponseType>>) -> ()) -> URLSessionTask {
        var urlRequest = URLRequest(url: request.baseURL)
        urlRequest.httpMethod = request.method.value
        urlRequest.allHTTPHeaderFields = request.allHTTPHeaderFields
        urlRequest.httpBody = request.graphQLQuery.data(using: .utf8)

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
    public func send<T: Request>(_ request: T) -> Observable<Response<T.ResponseType>> {
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
