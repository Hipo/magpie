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

    private let _encode: (Encoder) throws -> Void

    public init<T: Encodable>(_ base: T) {
        self._encode = { encoder in
            var container = encoder.singleValueContainer()
            try container.encode(base)
        }
    }

    public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
