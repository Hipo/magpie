//
//  Path.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 21.10.2018.
//

import Foundation

public struct Path {
    let value: String
    var queryParams: Params?
    
    public init(_ path: String) {
        self.value = path
    }
    
    public mutating func with(query queryParams: Params?) {
        self.queryParams = queryParams
    }
}

extension Path: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self = Path(value)
    }
}
