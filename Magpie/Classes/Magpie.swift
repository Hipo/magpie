//
//  Magpie.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

open class Magpie<Networking> where Networking: NetworkingProtocol {
    public var base: String
    public let networking: Networking
    
    open var commonHttpHeaders: HTTPHeaders {
        return [
            .accept("application/json"),
            .contentType("application/json")
        ]
    }

    private var taskBin = TaskBin()

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
    
    public func sendInvalidated<ObjectType>(_ endpoint: Endpoint<ObjectType>) -> EndpointInteractable where ObjectType: Mappable {
        var request = endpoint.request
        
        if request.base.isEmpty {
            request.base = base
        }
        
        request.magpie = self
        request.httpHeaders.merge(with: commonHttpHeaders)
        
        request.sendInvalidated()
        
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
        taskBin.cancelAndRemoveAll(for: path)
    }
    
    public func cancelEndpoints(relativeTo path: Path) {
        taskBin.cancelAndRemoveAll(relativeTo: path)
    }
    
    public func cancelAllEndpoints() {
        taskBin.cancelAndRemoveAll()
    }
}

extension Magpie: MagpieInteractable {
    func send<ObjectType>(_ request: Request<ObjectType>) -> TaskCancellable? where ObjectType: Mappable {
        let task = networking.send(request) { [weak self] dataResponse in
            self?.taskBin.removeTask(for: request)
            request.handle(dataResponse)
        }

        if let someTask = task {
            taskBin.save(someTask, for: request)
        }
        return task
    }
    
    func sendInvalidated<ObjectType>(_ request: Request<ObjectType>) -> TaskCancellable? where ObjectType: Mappable {
        let task = networking.sendInvalidated(request) { [weak self] dataResponse in
            self?.taskBin.removeTask(for: request)
            request.handle(dataResponse)
        }

        if let someTask = task {
            taskBin.save(someTask, for: request)
        }
        return task
    }
    
    func upload<ObjectType>(_ request: Request<ObjectType>, withData data: Data) -> TaskCancellable? where ObjectType : Mappable {
        let task = networking.upload(request, withData: data, handler: { [weak self] dataResponse in
            self?.taskBin.removeTask(for: request)
            request.handle(dataResponse)
        })

        if let someTask = task {
            taskBin.save(someTask, for: request)
        }
        return task
    }

    func retry<ObjectType>(_ request: Request<ObjectType>) -> TaskCancellable? where ObjectType: Mappable {
        let task = networking.send(request) { [weak self] dataResponse in
            self?.taskBin.removeTask(for: request)
            request.handle(dataResponse)
        }

        if let someTask = task {
            taskBin.save(someTask, for: request)
        }
        return task
    }
    
    func cancel<ObjectType>(_ request: Request<ObjectType>) where ObjectType: Mappable {
        taskBin.removeTask(for: request)
        networking.cancel(request)
    }
}
