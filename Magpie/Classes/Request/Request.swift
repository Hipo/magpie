//
//  Request.swift
//  Magpie
//
//  Created by Eray on 12.09.2018.
//

import Foundation

public struct Request<ObjectType> where ObjectType: Mappable  {
    public typealias Handler = ResponseHandler<ObjectType>

    public internal(set) var base = ""
    public internal(set) var path: Path
    public internal(set) var httpMethod: HTTPMethod = .get
    public internal(set) var httpHeaders: HTTPHeaders = []
    public internal(set) var bodyParams: Params?
    public internal(set) var cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    public internal(set) var timeout: TimeInterval = 60.0
    
    public internal(set) var handler: Handler?

    public internal(set) var task: TaskCancellable?

    weak var magpie: MagpieOperatable?

    init(path: Path) {
        self.path = path
    }
}

extension Request {
    public func asURLRequest() throws -> URLRequest {
        if base.isEmpty {
            throw Error.requestEncoding(.emptyOrInvalidBaseURL(base))
        }
        
        guard let baseUrl = URL(string: base) else {
            throw Error.requestEncoding(.emptyOrInvalidBaseURL(base))
        }
        
        var components = URLComponents()
        
        components.scheme = baseUrl.scheme
        components.host = baseUrl.host
        components.path = path.value
        
        do {
            components.queryItems = try path.queryParams?.asQuery()
        } catch let error {
            throw error
        }
        
        guard let url = components.url else {
            throw Error.requestEncoding(.emptyOrInvalidURL(
                """
                Base: \(base)
                Path: \(path.value)
                Query: \(path.queryParams?.description ?? "null")
                """
                ))
        }
        
        var urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        
        urlRequest.httpShouldHandleCookies = false
        urlRequest.httpMethod = httpMethod.rawValue
        
        do {
            urlRequest.httpBody = try bodyParams?.asBody()
            
            if let body = urlRequest.httpBody {
                let contentLength = HTTPHeader.contentLength("\(body.count)")
                urlRequest.setValue(contentLength.value, forHTTPHeaderField: contentLength.header)
            }
        } catch let error {
            throw error
        }
        
        httpHeaders.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.header) }
        
        return urlRequest
    }
}

extension Request {
    func handle(_ dataResponse: DataResponse) {
        switch dataResponse {
        case .success(let data):
            do {
                if let d = data {
                    handler?(.success(try ObjectType.decoded(from: d)))
                    return
                }
                
                if let none = NoObject() as? ObjectType {
                    handler?(.success(none))
                    return
                }
                
                handler?(.failure(Error.responseSerialization(.emptyOrCorruptedData(nil))))
            } catch let error {
                handler?(.failure(
                    Error.responseSerialization(.jsonSerializationFailed(data, error)))
                )
            }
        case .failure(let error):
            handler?(.failure(error))
        }
    }
}

extension Request: EndpointOperatable {
    public mutating func send() {
        task = magpie?.send(self)
    }

    public mutating func retry() {
        task = magpie?.retry(self)
    }

    public mutating func invalidate() {
        magpie?.cancel(self)
        task = nil
    }
}
