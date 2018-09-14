//
//  Magpie.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

open class Magpie<TheNetworking: Networking> {
    internal typealias TheRequest = Request<TheNetworking>
    
    /// MARK: Variables
    open var apiBase: String {
        fatalError("You should return a non-empty api base string here.")
    }
    
    fileprivate let networking: TheNetworking
    
    /// MARK: Initialization
    required public init(networking: TheNetworking = TheNetworking()) {
        self.networking = networking
    }
    
    /// MARK: Open+Operations
    /// TODO: Think of a nice way to generate&send the request.
    open func generateAndSendRequest() -> RequestOperatable {
        let req = generateRequest()
        
        req.original = sendRequest(req)
        
        return req
    }
    
    open func cancelOngoingRequests() {
        networking.cancelOngoingRequests()
    }
}

/// MARK: Operations
internal extension Magpie {
    @discardableResult
    func sendRequest(_ request: TheRequest) -> TheNetworking.TheRequest {
        return networking.sendRequest(request)
    }
    
    @discardableResult
    func retryRequest(_ request: TheRequest) -> TheNetworking.TheRequest {
        return networking.sendRequest(request)
    }
    
    func cancelRequest(_ request: TheRequest) {
        networking.cancelRequest(request)
    }
}

/// MARK: Builder
fileprivate extension Magpie {
    func generateRequest() -> TheRequest {
        let req = TheRequest(base: apiBase)
        
        req.magpie = self
        
        return req
    }
}
