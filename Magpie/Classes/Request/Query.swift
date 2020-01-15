//
//  Query.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 30.03.2019.
//

import Foundation

public protocol Query: Printable {
    var params: [QueryParamConvertible] { get }
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
        return try encoder.encode(params)
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

public protocol QueryKey {
    var description: String { get }
}

public protocol QueryParamConvertible: Printable {
    var key: QueryKey { get }
    var value: URLParamValueEncodable? { get }
}

extension QueryParamConvertible {
    /// <mark> CustomStringConvertible
    public var description: String {
        return "\(key):\(value?.description ?? "<nil>")"
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

    func encode(_ params: [QueryParamConvertible]) throws -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []

        for param in params {
            do {
                queryItems.append(URLQueryItem(name: param.key.description, value: try param.value?.urlEncoded(encodingStrategy)))
            } catch {
                throw RequestEncodingError.Reason.invalidURLQueryEncoding(key: param.key.description)
            }
        }
        return queryItems
    }
}
