//
//  Magpie.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

open class Magpie<TheNetworking: Networking> {
    internal typealias TheRequest<C: Decodable> = Request<TheNetworking, C>
    
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
    open func sendRequest<C: Decodable>(
        for objectTypeToParse: C.Type,
        withPath path: String,
        headers: [String: String]? = nil,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        _ responseClosure: @escaping ResponseClosure
        ) -> RequestOperatable {
        
        let request = TheRequest<C>(
            base: apiBase,
            path: path,
            headers: headers,
            method: method,
            parameters: parameters,
            encoding: encoding,
            responseClosure: responseClosure
        )

        request.magpie = self
        request.original = sendRequest(request)
        
        return request
    }
    
    open func cancelOngoingRequests() {
        networking.cancelOngoingRequests()
    }
}

/// MARK: Operations

internal extension Magpie {
    
    @discardableResult
    func sendRequest<C: Decodable>(_ request: TheRequest<C>) -> TheNetworking.TheRequest? {
        return networking.sendRequest(request)
    }
    
    @discardableResult
    func retryRequest<C: Decodable>(_ request: TheRequest<C>) -> TheNetworking.TheRequest? {
        return networking.sendRequest(request)
    }

    func cancelRequest<C: Decodable>(_ request: TheRequest<C>) {
        networking.cancelRequest(request)
    }
}
