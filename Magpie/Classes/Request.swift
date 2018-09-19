//
//  Request.swift
//  Magpie
//
//  Created by Eray on 12.09.2018.
//

import Foundation

open class Request<TheNetworking: Networking, CodableObject: Codable> {
    
    /// MARK: Properties
    
    public let base: String
    public var path: String
    public var headers: [String: String]?
    public var method: HTTPMethod?
    public var parameters: Parameters?
    public var encoding: ParameterEncoding?
    public var responseClosure: ResponseClosure
    
    internal var original: TheNetworking.TheRequest?
    internal weak var magpie: Magpie<TheNetworking>?
    
    /// MARK: Initialization
    
    init(
        base: String,
        path: String,
        headers: [String: String]?,
        method: HTTPMethod?,
        parameters: Parameters?,
        encoding: ParameterEncoding?,
        responseClosure: @escaping ResponseClosure
    ) {
        self.base = base
        self.path = path
        self.headers = headers
        self.method = method
        self.parameters = parameters
        self.encoding = encoding
        self.responseClosure = responseClosure
    }
}

extension Request: RequestOperatable {
    public func send() {
        magpie?.sendRequest(self)
    }
    
    public func retry() {
        magpie?.retryRequest(self)
    }
    
    public func cancel() {
        magpie?.cancelRequest(self)
    }
}
