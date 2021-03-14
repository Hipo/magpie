//
//  Model.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Foundation

public protocol Model: Codable, DebugPrintable {
    var isFault: Bool { get }

    static var encodingStrategy: JSONEncodingStrategy { get }
    static var decodingStrategy: JSONDecodingStrategy { get }

    func encoded() throws -> Data
    static func decoded(_ data: Data) throws -> Self
}

extension Model {
    public var isFault: Bool {
        return false
    }

    public static var encodingStrategy: JSONEncodingStrategy {
        return JSONEncodingStrategy()
    }
    public static var decodingStrategy: JSONDecodingStrategy {
        return JSONDecodingStrategy()
    }

    public func encoded() throws -> Data {
        return try encoded(Self.encodingStrategy)
    }

    public static func decoded(_ data: Data) throws -> Self {
        return try decoded(data, using: Self.decodingStrategy)
    }
}

extension Model {
    public static func decoded(
        fromResource name: String,
        withExtension ext: String = "json"
    ) throws -> Self {
        let someResourceUrl =
            Bundle.main.url(
                forResource: name,
                withExtension: ext
            )

        guard let resourceUrl = someResourceUrl else {
            fatalError("The resource not found!")
        }
        do {
            let data = try Data(contentsOf: resourceUrl, options: Data.ReadingOptions.uncached)
            return try decoded(
                data,
                using: Self.decodingStrategy
            )
        } catch let err {
            throw err
        }
    }
}

extension Model {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        do {
            let data = try encoded()
            return "[\(type(of: self))] \(data.utf8Description)"
        } catch {
            return "<invalid>"
        }
    }
}

extension Array: Model where Element: Model {
    public func encoded() throws -> Data {
        return try encoded(Element.encodingStrategy)
    }

    public static func decoded(_ data: Data) throws -> Self {
        return try decoded(data, using: Element.decodingStrategy)
    }
}

public struct NoModel: Model { }
