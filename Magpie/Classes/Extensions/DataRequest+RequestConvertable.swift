//
//  DataRequest+RequestConvertable.swift
//  Magpie
//
//  Created by Eray on 29.09.2018.
//

import Foundation
import Alamofire

extension DataRequest: RequestConvertible {
    public var path: String {
        get {
            fatalError("Must not be called from anywhere")
        }
        set {
            fatalError("Must not be called from anywhere")
        }
    }
    
    public var headers: [String : String]? {
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
