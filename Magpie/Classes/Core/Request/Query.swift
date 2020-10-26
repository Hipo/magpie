//
//  Query.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 30.03.2019.
//

import Foundation

public protocol Query: Printable {
    func encoded() throws -> [URLQueryItem]
}

extension Query {
    func encodedString() throws -> String? {
        var urlComponents = URLComponents()
        urlComponents.queryItems = try encoded()
        return urlComponents.query
    }
}

extension Query {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        do {
            return try encodedString() ?? "<nil>"
        } catch {
            return "<invalid>"
        }
    }
}

public protocol ObjectQuery: Query {
    associatedtype SomeObjectQueryKeyedParam: ObjectQueryKeyedParamConvertible

    var queryParams: [SomeObjectQueryKeyedParam] { get }
    var encodingStrategy: URLEncodingStrategy { get }
}

extension ObjectQuery {
    public var encodingStrategy: URLEncodingStrategy {
        return URLEncodingStrategy()
    }

    public func encoded() throws -> [URLQueryItem] {
        var encoder = ObjectQueryEncoder<SomeObjectQueryKeyedParam>()
        encoder.encodingStrategy = encodingStrategy
        return try encoder.encode(queryParams)
    }
}

public protocol ObjectQueryKeyedParamConvertible: Printable {
    associatedtype Key: CodingKey

    var key: Key { get }
    var encodingValue: URLParamValueEncodable? { get }
}

extension ObjectQueryKeyedParamConvertible {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "\(key.stringValue):\(encodingValue?.debugDescription ?? "<nil>")"
    }
}

public struct ObjectQueryKeyedParam<Key: CodingKey>: ObjectQueryKeyedParamConvertible {
    public let key: Key
    public let encodingValue: URLParamValueEncodable?

    public init(
        _ key: Key,
        _ encodingValue: URLParamValueEncodable?
    ) {
        self.key = key
        self.encodingValue = encodingValue
    }
}

private struct ObjectQueryEncoder<Param: ObjectQueryKeyedParamConvertible> {
    var encodingStrategy: URLEncodingStrategy = URLEncodingStrategy()

    func encode(_ queryParams: [Param]) throws -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []

        for param in queryParams {
            do {
                let value = try param.encodingValue.map { escape(try $0.urlEncoded(encodingStrategy)) }
                queryItems.append(URLQueryItem(name: escape(param.key.stringValue), value: value))
            } catch {
                throw RequestEncodingError.Reason.invalidURLQueryEncoding(key: param.key.stringValue)
            }
        }
        return queryItems
    }
}

extension ObjectQueryEncoder {
    private func escape(_ string: String) -> String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove("+")
        return string.addingPercentEncoding(withAllowedCharacters: allowed)!
    }
}
