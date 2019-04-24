//
//  Method.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 21.10.2018.
//

import Foundation

public enum Method: String {
    case get = "GET"
    case head = "HEAD"
    case delete = "DELETE"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
}

extension Method {
    public func decoded() -> String {
        return rawValue
    }
}

extension Method: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return decoded()
    }
}
