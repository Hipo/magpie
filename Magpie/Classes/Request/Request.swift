//
//  Request.swift
//  Magpie
//
//  Created by Eray on 12.09.2018.
//

import Foundation

public struct Request<ObjectType> where ObjectType: Mappable  {
    public typealias ObjectRef = ObjectType
    public typealias Handler = ResponseHandler<ObjectType>

    public internal(set) var base = ""
    public internal(set) var path: Path
    public internal(set) var httpMethod: HTTPMethod = .get
    public internal(set) var httpHeaders: HTTPHeaders = []
    public internal(set) var bodyParams: Params?
    public internal(set) var cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    public internal(set) var timeout: TimeInterval = 60.0
    
    public internal(set) var handler: Handler?

    public internal(set) var task: TaskCancellable?

    weak var magpie: MagpieInteractable?

    init(path: Path) {
        self.path = path
    }
}

extension Request {
    func handle(_ dataResponse: DataResponse) {
        switch dataResponse {
        case .success(let data):
            do {
                if let none = NoObject() as? ObjectType {
                    handler?(.success(none))
                    return
                }
                
                if let d = data {
                    handler?(.success(try ObjectType.decoded(from: d)))
                    return
                }
                
                handler?(.failure(Error.responseSerialization(.emptyOrCorruptedData(nil))))
            } catch let error {
                handler?(.failure(
                    Error.responseSerialization(.jsonSerializationFailed(data, error)))
                )
            }
        case .failure(let error):
            handler?(.failure(error))
        }
    }
}

extension Request: RequestConvertible {
}

extension Request: EndpointInteractable {
    public mutating func send() {
        task = magpie?.send(self)
    }
    
    public mutating func sendInvalidated() {
        task = magpie?.sendInvalidated(self)
    }
    
    public mutating func upload(data: Data) {
        task = magpie?.upload(self, withData: data)
    }

    public mutating func retry() {
        task = magpie?.retry(self)
    }

    public mutating func invalidate() {
        magpie?.cancel(self)
        task = nil
    }
}
