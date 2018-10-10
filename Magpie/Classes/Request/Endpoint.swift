//
//  Endpoint.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 10.10.2018.
//

import Foundation

public class Endpoint<ObjectType> where ObjectType: Mappable {
    typealias RequestRef = Request<ObjectType>
    
    var request: RequestRef
    
    public init(_ path: Path) {
        request = RequestRef(path: path)
    }
}

extension Endpoint {
    public func httpMethod(_ value: HTTPMethod) -> Endpoint {
        request.httpMethod = value
        return self
    }
    
    public func httpHeaders(_ value: HTTPHeaders) -> Endpoint {
        request.httpHeaders.merge(with: value)
        return self
    }
    
    public func query(_ value: Params?) -> Endpoint {
        request.path.with(query: value)
        return self
    }
    
    public func body(_ value: Params?) -> Endpoint {
        request.bodyParams = value
        return self
    }
    
    public func cachePolicy(_ value: URLRequest.CachePolicy) -> Endpoint {
        request.cachePolicy = value
        return self
    }
    
    public func timeout(_ value: TimeInterval) -> Endpoint {
        if value > 0 {
            request.timeout = value
        }
        return self
    }
    
    public func handler(_ closure: ResponseHandler<ObjectType>?) -> Endpoint {
        request.handler = closure
        return self
    }
}
