//
//  Typealiases.swift
//  Pods
//
//  Created by Eray on 1.10.2018.
//

// TODO: Split these from alamofire library

import Alamofire

public typealias HTTPHeaders = [String: String]
public typealias Parameters = [String: String]

public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

public typealias ParameterEncoding = Alamofire.ParameterEncoding
public typealias JSONEncoding = Alamofire.JSONEncoding
public typealias URLEncoding = Alamofire.URLEncoding
