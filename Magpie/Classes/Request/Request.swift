//
//  Request.swift
//  Magpie
//
//  Created by Eray on 12.09.2018.
//

import Foundation

public class Request  {
    public typealias CachePolicy = URLRequest.CachePolicy

    public var base: String
    public var path = ""
    public var method: Method = .get
    public var query: Query?
    public var body: Body?
    public var headers: Headers = []
    public var cachePolicy: CachePolicy = .reloadIgnoringLocalCacheData
    public var timeout: TimeInterval = 60.0

    public init(base: String) {
        self.base = base
    }
}

extension Request {
    public func asUrlRequest() throws -> URLRequest {
        guard let baseUrl = URL(string: base) else {
            throw RequestEncodingError(reason: .emptyOrInvalidURL)
        }
        do {
            var components = URLComponents()
            components.scheme = baseUrl.scheme
            components.host = baseUrl.host
            components.port = baseUrl.port
            components.path = baseUrl.path + path
            components.percentEncodedQueryItems = try query?.encoded()

            guard let url = components.url else {
                throw RequestEncodingError(reason: .emptyOrInvalidURL)
            }
            var urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
            urlRequest.httpMethod = method.description

            if let body = body {
                let httpBody = try body.encoded()
                urlRequest.httpBody = httpBody
                urlRequest.setValue(String(httpBody.count), forHTTPHeaderField: HTTPHeader.contentLength)
            }
            for header in headers {
                urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
            }
            return urlRequest
        } catch let error as RequestEncodingError.Reason {
            throw RequestEncodingError(reason: error)
        } catch let error {
            throw UnexpectedError(responseData: nil, underlyingError: error)
        }
    }
}

extension Request: Printable {
    /// <mark> CustomStringConvertible
    public var description: String {
        do {
            let urlRequest = try asUrlRequest()
            return "\(method.description) \(urlRequest.description)"
        } catch {
            return "<invalid>"
        }
    }
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        do {
            let urlRequest = try asUrlRequest()
            return urlRequest.asCURL() ?? urlRequest.debugDescription
        } catch {
            return "<invalid>"
        }
    }
}
