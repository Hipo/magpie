//
//  Magpie.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

open class Magpie<OuterNetworking: Networking> {
    public let base: String

    private let networking: OuterNetworking

    required public init(base: String, networking: OuterNetworking = OuterNetworking()) {
        self.base = base
        self.networking = networking
    }
}

extension Magpie {
    open func send<ObjectType>(
        _ endpoint: Endpoint<ObjectType>)
        -> EndpointOperatable
    where ObjectType: Mappable {
        var request = endpoint.request

        if request.base.isEmpty {
            request.base = base
        }

        request.magpie = self
        request.send()
        
        return request
    }

    open func cancelAllEndpoints() {
        networking.cancelAll()
    }
    
    // TODO: Add a method to cancel endpoints using a path.
}

extension Magpie: MagpieOperatable {
    func send<ObjectType>(
        _ request: Request<ObjectType>)
        -> TaskCancellable?
    where ObjectType: Mappable {
        return networking.send(request) { request.handle($0) }
    }

    func retry<ObjectType>(
        _ request: Request<ObjectType>)
        -> TaskCancellable?
    where ObjectType: Mappable {
        return networking.send(request) { request.handle($0) }
    }
    
    func cancel<ObjectType>(_ request: Request<ObjectType>) where ObjectType: Mappable {
        networking.cancel(request)
    }
}
