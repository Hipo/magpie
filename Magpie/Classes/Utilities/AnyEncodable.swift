//
//  AnyEncodable.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 1.04.2019.
//

import Foundation

public struct AnyEncodable: Encodable, CustomStringConvertible {
    public var description: String {
        return ""
    }

    private let base: Encodable

    public init<T: Encodable>(_ base: T) {
        self.base = base
    }

    public func encode(to encoder: Encoder) throws {
        return try base.encode(to: encoder)
    }
}
