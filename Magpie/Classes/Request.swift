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
    
    internal var original: TheNetworking.TheRequest?
    internal weak var magpie: Magpie<TheNetworking>?
    
    /// MARK: Initialization
    
    init(
        base: String,
        path: String,
        headers: [String: String]?,
        method: HTTPMethod?,
        parameters: Parameters?,
        encoding: ParameterEncoding?
    ) {
        self.base = base
        self.path = path
        
        self.method = method
        self.parameters = parameters
        self.encoding = encoding
    }
}

extension Request: RequestOperatable {
    public func send(_ responseClosure: @escaping ResponseClosure) {
        magpie?.sendRequest(self, responseClosure)
    }
    
    public func retry(_ responseClosure: @escaping ResponseClosure) {
        magpie?.retryRequest(self, responseClosure)
    }
    
    public func cancel() {
        magpie?.cancelRequest(self)
    }
}
