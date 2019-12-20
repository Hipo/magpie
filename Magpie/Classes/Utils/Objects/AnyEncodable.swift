//
//  AnyEncodable.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 1.04.2019.
//

import Foundation

public struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    private let _describe: () -> String

    public init<T: Encodable>(_ base: T) {
        _encode = { encoder in
            var container = encoder.singleValueContainer()
            try container.encode(base)
        }
        _describe = {
            return "\(base)"
        }
    }

    public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

extension AnyEncodable: Printable {
    /// <mark> CustomStringConvertible
    public var description: String {
        return _describe()
    }
}
