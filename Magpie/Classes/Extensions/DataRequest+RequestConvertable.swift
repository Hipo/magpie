//
//  DataRequest+RequestConvertable.swift
//  Magpie
//
//  Created by Eray on 29.09.2018.
//

import Foundation
import Alamofire

extension DataRequest: RequestConvertable {
    private static var parameters = [String: Parameters]()
    private static var encoding = [String: ParameterEncoding]()
    
    public var path: String {
        return request?.url?.absoluteString ?? String()
    }
    
    public var headers: [String : String]? {
        return request?.allHTTPHeaderFields
    }
    
    public var method: HTTPMethod {
        let httpMethod = request?.httpMethod ?? HTTPMethod.get.rawValue
        
        return HTTPMethod(rawValue: httpMethod) ?? HTTPMethod.get
    }
    
    public var parameters: Parameters? {
        get {
            let tmpAddress = String(
                format: "%p",
                unsafeBitCast(self, to: Int.self)
            )
            
            return DataRequest.parameters[tmpAddress]
        }
        set(newValue) {
            let tmpAddress = String(
                format: "%p",
                unsafeBitCast(self, to: Int.self)
            )
            
            DataRequest.parameters[tmpAddress] = newValue
        }
    }
    
    public var encoding: ParameterEncoding {
        get {
            let tmpAddress = String(
                format: "%p",
                unsafeBitCast(self, to: Int.self)
            )
            
            return DataRequest.encoding[tmpAddress] ?? URLEncoding.default
        }
        set(newValue) {
            let tmpAddress = String(
                format: "%p",
                unsafeBitCast(self, to: Int.self)
            )
            
            DataRequest.encoding[tmpAddress] = newValue
        }
    }
}
