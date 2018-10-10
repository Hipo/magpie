//
//  Response.swift
//  Pods
//
//  Created by Eray on 19.09.2018.
//

import Foundation

public typealias ResponseHandler<ObjectType> =
    (Response<ObjectType>) -> Void where ObjectType: Mappable

public enum Response<ObjectType> where ObjectType: Mappable {
    case success(ObjectType)
    case failure(Error)
}

extension Response {
    public var isFailed: Bool {
        if case .success = self {
            return false
        }
        return true
    }
    
    public var object: ObjectType? {
        if case .success(let object) = self {
            return object
        }
        return nil
    }
    
    public var error: Error? {
        if case .failure(let err) = self {
            return err
        }
        
        return nil
    }
}
