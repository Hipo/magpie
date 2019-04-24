//
//  Query.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 30.03.2019.
//

import Foundation

public protocol Query: CustomStringConvertible, CustomDebugStringConvertible {
    associatedtype Key: RequestParameter
    typealias Pair = QueryPair<Key>

    func decoded() -> [Pair]?
}

extension Query {
    public var description: String {
        do {
            return (try encodedString()).absoluteDescription
        } catch {
            return "<invalid>"
        }
    }
}

extension Query {
    func encodedString() throws -> String? {
        let encoder = QueryEncoder(query: self)

        var urlComponents = URLComponents()
        urlComponents.queryItems = try encoder.encode()
        return urlComponents.query
    }
}

public struct QueryEncodingStrategy {
    public enum Null {
        case `default` /// nil
        case empty /// ""
        case dash /// "-"
        case string /// "null"
        case other(String) /// "{string}"
    }

    public enum Boolean {
        case `default`
        case number
    }

    let null: Null
    let boolean: Boolean

    public init(
        null: Null = .default,
        boolean: Boolean = .default
    ) {
        self.null = null
        self.boolean = boolean
    }
}

extension QueryEncodingStrategy: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return """
        for null values: \(null.description)
        for boolean values: \(boolean.description)
        """
    }
}

extension QueryEncodingStrategy.Null {
    func encoded() -> String? {
        switch self {
        case .default:
            return nil
        case .empty:
            return ""
        case .dash:
            return "-"
        case .string:
            return "null"
        case .other(let string):
            return string
        }
    }
}

extension QueryEncodingStrategy.Null: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return encoded().absoluteDescription
    }
}

extension QueryEncodingStrategy.Boolean {
    func encoded(boolean: Bool) -> String {
        switch self {
        case .default:
            return boolean ? "true" : "false"
        case .number:
            return boolean ? "1" : "0"
        }
    }
}

extension QueryEncodingStrategy.Boolean: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "\(encoded(boolean: true))/\(encoded(boolean: false))"
    }
}

public struct QueryPair<Key: RequestParameter> {
    public enum Value {
        case null
        case shared
        case some(QueryPairValue)
    }

    let key: Key
    let value: Value

    public init(
        key: Key,
        value: Value
    ) {
        self.key = key
        self.value = value
    }
}

extension QueryPair {
    func encoded(using encodingStrategy: QueryEncodingStrategy) throws -> URLQueryItem {
        switch value {
        case .null:
            return URLQueryItem(name: key.toString(), value: encodingStrategy.null.encoded())
        case .shared:
            guard let sharedValue = key.sharedValue() else {
                throw Error.requestEncoding(.invalidSharedURLQueryPair(key))
            }
            guard let someValue = sharedValue.queryValue() else {
                return URLQueryItem(name: key.toString(), value: encodingStrategy.null.encoded())
            }
            if let booleanValue = someValue as? Bool {
                return URLQueryItem(name: key.toString(), value: booleanValue.toString(for: encodingStrategy.boolean))
            }
            return URLQueryItem(name: key.toString(), value: try someValue.toString())
        case .some(let someValue):
            return URLQueryItem(name: key.toString(), value: try someValue.toString())
        }
    }
}

extension QueryPair: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        do {
            var urlComponents = URLComponents()
            urlComponents.queryItems = [try encoded(using: QueryEncodingStrategy())]
            return """
            \(urlComponents.query.absoluteDescription)
            [The actual values may be different considering the QueryEncodingStrategy instance to be used]
            """
        } catch {
            return "<invalid>"
        }
    }
}

public protocol QueryPairValue: CustomStringConvertible, CustomDebugStringConvertible {
    func toString() throws -> String
}

extension QueryPairValue {
    public var description: String {
        do {
            return try toString()
        } catch {
            return "<invalid>"
        }
    }
}

extension String: QueryPairValue {
    public func toString() throws -> String {
        return self
    }
}

extension Int: QueryPairValue {
    public func toString() throws -> String {
        return String(self)
    }
}

extension Float: QueryPairValue {
    public func toString() throws -> String {
        return String(self)
    }
}

extension Double: QueryPairValue {
    public func toString() throws -> String {
        return String(self)
    }
}

extension Bool: QueryPairValue {
    public func toString() throws -> String {
        return toString(for: .default)
    }

    func toString(for strategy: QueryEncodingStrategy.Boolean) -> String {
        return strategy.encoded(boolean: self)
    }
}

extension Array: QueryPairValue where Element: QueryPairValue {
    public func toString() throws -> String {
        let values = try self.map { try $0.toString() }
        return "[\(values.joined(separator: ","))]"
    }
}

extension Dictionary: QueryPairValue where Key: RequestParameter, Value: QueryPairValue {
    public func toString() throws -> String {
        let values = try self.map { "\($0.key.toString()):\(try $0.value.toString())" }
        return "{\(values.joined(separator: ","))}"
    }
}

protocol QueryEncoding {
    mutating func setIfNeeded(_ encodingStrategy: QueryEncodingStrategy)

    func encode() throws -> [URLQueryItem]?
}

struct QueryEncoder<T: Query>: QueryEncoding {
    let query: T

    private var encodingStrategy: QueryEncodingStrategy?

    init(
        query: T,
        encodingStrategy: QueryEncodingStrategy? = nil
    ) {
        self.query = query
        self.encodingStrategy = encodingStrategy
    }

    mutating func setIfNeeded(_ encodingStrategy: QueryEncodingStrategy) {
        if self.encodingStrategy == nil {
            self.encodingStrategy = encodingStrategy
        }
    }

    func encode() throws -> [URLQueryItem]? {
        guard let pairs = query.decoded(), !pairs.isEmpty else {
            return nil
        }
        var queryItems: [URLQueryItem] = []
        for pair in pairs {
            do {
                let queryItem = try pair.encoded(using: encodingStrategy ?? QueryEncodingStrategy())
                queryItems.append(queryItem)
            } catch let error {
                throw Error.requestEncoding(.invalidURLQueryPair(pair.key, error))
            }
        }
        return queryItems
    }
}
