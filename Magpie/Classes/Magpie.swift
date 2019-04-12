//
//  Magpie.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

open class Magpie<Networking> where Networking: NetworkingProtocol {
    public let base: String
    public let networking: Networking
    
    open var commonHttpHeaders: HTTPHeaders {
        return [
            .accept("application/json"),
            .contentType("application/json")
        ]
    }

    private var requestBin = RequestBin()

    public required init(
        base: String,
        networking: Networking = Networking()
    ) {
        self.base = base
        self.networking = networking
    }
}

extension Magpie {
    public func send<ObjectType>(_ endpoint: Endpoint<ObjectType>) -> EndpointInteractable where ObjectType: Mappable {
        var request = endpoint.request

        if request.base.isEmpty {
            request.base = base
        }

        request.magpie = self
        request.httpHeaders.merge(with: commonHttpHeaders)
        
        request.send()
        
        return request
    }
    
    public func upload<ObjectType>(data: Data, toEndpoint endpoint: Endpoint<ObjectType>) -> EndpointInteractable where ObjectType: Mappable {
        var request = endpoint.request
        
        if request.base.isEmpty {
            request.base = base
        }
        
        request.magpie = self
        request.httpHeaders.merge(with: commonHttpHeaders)
        
        request.upload(data: data)
        
        return request
    }

    public func cancelEndpoints(with path: Path) {
        requestBin.invalidateAndRemoveRequests(with: path)
    }
    
    public func cancelEndpoints(relativeTo path: Path) {
        requestBin.invalidateAndRemoveRequests(relativeTo: path)
    }
    
    public func cancelAllEndpoints() {
        requestBin.invalidateAndRemoveAll()
    }
}

extension Magpie: MagpieInteractable {
    func send<ObjectType>(_ request: Request<ObjectType>) -> TaskCancellable? where ObjectType: Mappable {
        requestBin.append(request)
        return networking.send(request) { [weak self] dataResponse in
            self?.requestBin.remove(request)
            request.handle(dataResponse)
        }
    }
    
    func sendInvalidated<ObjectType>(_ request: Request<ObjectType>) -> TaskCancellable? where ObjectType: Mappable {
        requestBin.append(request)
        return networking.sendInvalidated(request) { [weak self] dataResponse in
            self?.requestBin.remove(request)
            request.handle(dataResponse)
        }
    }
    
    func upload<ObjectType>(_ request: Request<ObjectType>, withData data: Data) -> TaskCancellable? where ObjectType : Mappable {
        requestBin.append(request)
        return networking.upload(request, withData: data, handler: { [weak self] dataResponse in
            self?.requestBin.remove(request)
            request.handle(dataResponse)
        })
    }

    func retry<ObjectType>(_ request: Request<ObjectType>) -> TaskCancellable? where ObjectType: Mappable {
        requestBin.append(request)
        return networking.send(request) { [weak self] dataResponse in
            self?.requestBin.remove(request)
            request.handle(dataResponse)
        }
    }
    
    func cancel<ObjectType>(_ request: Request<ObjectType>) where ObjectType: Mappable {
        requestBin.remove(request)
        networking.cancel(request)
    }
}
