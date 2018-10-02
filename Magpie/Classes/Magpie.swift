//
//  Magpie.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

open class Magpie<TheNetworking: Networking> {
    internal typealias TheRequest<D: Decodable> = Request<TheNetworking, D>
    
    /// MARK: Variables
    open var apiBase: String {
        fatalError("You should return a non-empty api base string here.")
    }
    
    fileprivate let networking: TheNetworking
    fileprivate var requests = [RequestProtocol]()
    
    /// MARK: Initialization
    required public init(networking: TheNetworking = TheNetworking()) {
        self.networking = networking
    }
    
    /// MARK: Open+Operations
    /// TODO: Think of a nice way to generate&send the request.
    open func sendRequest<D: Decodable>(
        for objectTypeToParse: D.Type,
        withPath path: String,
        headers: [String: String]? = nil,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        _ responseClosure: @escaping ResponseClosure
        ) -> RequestOperatable {
        
        let request = TheRequest<D>(
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
        
        requests.append(request)

        return request
    }
    
    open func cancelOngoingRequests() {
        networking.cancelOngoingRequests()
    }
    
    open func cancelRequest(withPath path: String) {
        requests.forEach { (aRequest) in
            if aRequest.path != path {
                return
            }
            
            aRequest.cancel()
        }
    }
}

/// MARK: Operations

internal extension Magpie {
    @discardableResult
    func sendRequest<D: Decodable>(_ request: TheRequest<D>) -> TheNetworking.TheRequest? {
        return networking.sendRequest(request)
    }
    
    @discardableResult
    func retryRequest<D: Decodable>(_ request: TheRequest<D>) -> TheNetworking.TheRequest? {
        return networking.sendRequest(request)
    }

    func cancelRequest<D: Decodable>(_ request: TheRequest<D>) {
        networking.cancelRequest(request)
    }
}
