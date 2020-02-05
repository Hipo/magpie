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

public protocol QueryParamConvertible: Printable {
    var key: QueryKey { get }
    var value: URLParamValueEncodable? { get }
}

extension QueryParamConvertible {
    /// <mark> CustomStringConvertible
    public var description: String {
        return "\(key.description):\(value?.description ?? "<nil>")"
    }
}

public struct QueryParam: QueryParamConvertible {
    public let key: QueryKey
    public let value: URLParamValueEncodable?

    public init(
        _ key: QueryKey,
        _ value: URLParamValueEncodable?
    ) {
        self.key = key
        self.value = value
    }
}

private struct QueryEncoder {
    var encodingStrategy: URLEncodingStrategy = URLEncodingStrategy()

    func encode(_ queryParams: [QueryParamConvertible]) throws -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []

        for param in queryParams {
            do {
                queryItems.append(URLQueryItem(name: param.key.encoded(), value: try param.value?.urlEncoded(encodingStrategy)))
            } catch {
                throw RequestEncodingError.Reason.invalidURLQueryEncoding(key: param.key.encoded())
            }
        }
        return queryItems
    }
}
