//
//  Model.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Foundation

public protocol Model: Codable, Printable {
    var encodingStrategy: JSONEncodingStrategy { get }
    static var decodingStrategy: JSONDecodingStrategy { get }
}

extension Model {
    public var encodingStrategy: JSONEncodingStrategy {
        return JSONEncodingStrategy()
    }
    public static var decodingStrategy: JSONDecodingStrategy {
        return JSONDecodingStrategy()
    }
}

extension Model {
    func encoded() throws -> Data {
        return try encoded(encodingStrategy)
    }

    static func decoded(_ data: Data) throws -> Self {
        return try decoded(data, using: Self.decodingStrategy)
    }
}

extension Model {
    /// <mark> CustomStringConvertible
    public var description: String {
        do {
            let data = try encoded()
            return "[\(type(of: self))]\(data.utf8Description)"
        } catch {
            return "<invalid>"
        }
    }
}

public struct NoModel: Model { }

extension Array: Model where Element: Model { }
