//
//  Request.swift
//  Magpie
//
//  Created by Eray on 12.09.2018.
//

import Foundation
import Alamofire

public struct Request {
    let headers: [String: String]?
    let url: URL
    let method: HTTPMethod
    let parameters: Parameters?
    let encoding: ParameterEncoding?
    
    public init(
        headers: [String: String]? = nil,
        url: URL,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding? = nil) {
        
        self.headers = headers
        self.url = url
        self.method = method
        self.parameters = parameters
        self.encoding = encoding
    }
}
