//
//  Request.swift
//  Magpie
//
//  Created by Eray on 12.09.2018.
//

import Foundation

open class Request<TheNetworking: Networking> {
    /// MARK: Variables
    open let base: String
    
    internal var original: TheNetworking.TheRequest?
    internal weak var magpie: Magpie<TheNetworking>?
    
    /// MARK: Initialization
    init(base: String) {
        self.base = base
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
