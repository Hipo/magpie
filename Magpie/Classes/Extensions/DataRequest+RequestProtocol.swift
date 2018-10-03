//
//  DataRequest+RequestConvertable.swift
//  Magpie
//
//  Created by Eray on 29.09.2018.
//

import Foundation
import Alamofire

extension DataRequest: RequestProtocol { }

extension DataRequest: RequestConvertible {
    public var decodableObjectType: Decodable.Type? {
        fatalError("Must not be called from anywhere")
    }
    
    public var base: String {
        fatalError("Must not be called from anywhere")
    }
    
    public var responseClosure: ResponseClosure {
        fatalError("Must not be called from anywhere")
    }
    
    public var original: RequestProtocol? {
        get {
            fatalError("Must not be called from anywhere")
        }
        set {
            fatalError("Must not be called from anywhere")
        }
    }
    
    public var path: String {
        get {
            fatalError("Must not be called from anywhere")
        }
        set {
            fatalError("Must not be called from anywhere")
        }
    }
    
    public var headers: [String: String]? {
        get {
            fatalError("Must not be called from anywhere")
        }
        set {
            fatalError("Must not be called from anywhere")
        }
    }
    
    public var method: HTTPMethod {
        get {
            fatalError("Must not be called from anywhere")
        }
        set {
            fatalError("Must not be called from anywhere")
        }
    }
        
    public var parameters: Parameters? {
        get {
            fatalError("Must not be called from anywhere")
        }
        set {
            fatalError("Must not be called from anywhere")
        }
    }
    
    public var encoding: ParameterEncoding {
        get {
            fatalError("Must not be called from anywhere")
        }
        set {
            fatalError("Must not be called from anywhere")
        }
    }
}

extension DataRequest: RequestOperatable {
    open func send() {

    }
    
    open func retry() {

    }
}
