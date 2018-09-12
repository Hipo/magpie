//
//  Api.swift
//  Pods
//
//  Created by Eray on 12.09.2018.
//

import Foundation
import Alamofire

public enum Response<ObjectType: Codable, Error: Swift.Error> {
    case success(ObjectType)
    case failed(Error)
}

open class API {
    public init() { }
    
    public func quickRequest<T: MagpieRequest>(_ url: URL, _ httpMethod: HTTPMethod) -> T {
        let request = T.init(httpMethod: httpMethod, url: url)

//        request.api = self

        sendRequest(request)

        return request
    }
    
    func sendRequest<T: MagpieRequest>(_ request: T) {
        Alamofire.request(request.url).validate().responseJSON { (response) in
            
        }
    }
    
    func cancelRequest<T: MagpieRequest>(_ request: T) {
//        req.internalRequest.cancel()
    }
}
