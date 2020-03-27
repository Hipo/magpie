//
//  Query.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 30.03.2019.
//

import Foundation

public protocol Query: Printable {
    var queryParams: [QueryParamConvertible] { get }
    var encodingStrategy: URLEncodingStrategy { get }

    func encoded() throws -> [URLQueryItem]
}

extension Query {
    public var encodingStrategy: URLEncodingStrategy {
        return URLEncodingStrategy()
    }

    public func encoded() throws -> [URLQueryItem] {
        var encoder = QueryEncoder()
        encoder.encodingStrategy = encodingStrategy
        return try encoder.encode(queryParams)
    }

    func encodedString() throws -> String? {
        var urlComponents = URLComponents()
        urlComponents.queryItems = try encoded()
        return urlComponents.query
    }
}

extension Query {
    /// <mark> CustomStringConvertible
    public var description: String {
        do {
            return try encodedString() ?? "<nil>"
        } catch {
            return "<invalid>"
        }
    }
}

public protocol QueryKey: Printable {
    func encoded() -> String
}

extension QueryKey where Self: RawRepresentable, Self.RawValue == String {
    public func encoded() -> String {
        return rawValue
    }
}

extension String: QueryKey {
    public func encoded() -> String {
        return self
    }
}

public protocol QueryParamConvertible: Printable {
    var key: QueryKey { get }
    var encodingValue: URLParamValueEncodable? { get }
}

extension QueryParamConvertible {
    /// <mark> CustomStringConvertible
    public var description: String {
        return "\(key.description):\(encodingValue?.description ?? "<nil>")"
    }
}

extension URLQueryItem: QueryParamConvertible {
    public var key: QueryKey {
        return name
    }
    public var encodingValue: URLParamValueEncodable? {
        return value
    }
}

public struct QueryParam: QueryParamConvertible {
    public let key: QueryKey
    public let encodingValue: URLParamValueEncodable?

    public init(
        _ key: QueryKey,
        _ encodingValue: URLParamValueEncodable?
    ) {
        self.key = key
        self.encodingValue = encodingValue
    }
}

private struct QueryEncoder {
    var encodingStrategy: URLEncodingStrategy = URLEncodingStrategy()

    func encode(_ queryParams: [QueryParamConvertible]) throws -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []

        for param in queryParams {
            do {
                let value = try param.encodingValue.map { escape(try $0.urlEncoded(encodingStrategy)) }
                queryItems.append(URLQueryItem(name: escape(param.key.encoded()), value: value))
            } catch {
                throw RequestEncodingError.Reason.invalidURLQueryEncoding(key: param.key.encoded())
            }
        }
        return queryItems
    }
}

extension QueryEncoder {
    private func escape(_ string: String) -> String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove("+")
        return string.addingPercentEncoding(withAllowedCharacters: allowed)!
    }
}
