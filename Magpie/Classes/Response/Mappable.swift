//
//  Mappable.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Foundation

public protocol Mappable: Decodable {
    static func decoded(from data: Data) throws -> Self
}

public extension Mappable {
    static func decoded(from data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}

extension Array: Mappable where Element: Mappable {
}

extension Dictionary: Mappable where Key == String, Value: Mappable {
}
