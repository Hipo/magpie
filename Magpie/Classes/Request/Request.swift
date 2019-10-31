//
//  Request.swift
//  Magpie
//
//  Created by Eray on 12.09.2018.
//

import Foundation

public class Request  {
    var base = ""
    var path: Path
    var httpMethod: Method = .get
    var queryEncoder: QueryEncoding?
    var httpBodyEncoder: BodyEncoding?
    var httpHeaders: Headers = []
    var cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    var timeout: TimeInterval = 60.0

    init(path: Path) {
        self.path = path
    }
}

extension Request {
    public func asUrlRequest() throws -> URLRequest {
        guard let baseUrl = URL(string: base) else {
            throw Error.requestEncoding(.emptyOrInvalidBaseURL(base))
        }

        do {
            var components = URLComponents()

            components.scheme = baseUrl.scheme
            components.host = baseUrl.host
            components.port = baseUrl.port
            components.path = baseUrl.path + path.decoded()

            if let queryEncoder = queryEncoder {
                components.queryItems = try queryEncoder.encode()
            }

            guard let url = components.url else {
                throw Error.requestEncoding(.emptyOrInvalidURL(self))
            }

            var urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)

            urlRequest.httpMethod = httpMethod.decoded()
            urlRequest.httpShouldHandleCookies = false

            if let encoder = httpBodyEncoder {
                if let httpBody = try encoder.encode() {
                    let field = Headers.Field.contentLength(.some(String(httpBody.count))).decoded()

                    urlRequest.httpBody = httpBody
                    urlRequest.setValue(field.value, forHTTPHeaderField: field.key)
                }
            }

            for field in httpHeaders {
                urlRequest.setValue(field.value, forHTTPHeaderField: field.key)
            }

            return urlRequest
        } catch let error {
            throw Error.requestEncoding(.failed(self, error))
        }
    }
}

extension Request: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        do {
            let urlRequest = try asUrlRequest()
            return "\(httpMethod.description) \(urlRequest.description)"
        } catch {
            return "<invalid>"
        }
    }

    public var debugDescription: String {
        do {
            let urlRequest = try asUrlRequest()
            return urlRequest.asCURL() ?? urlRequest.debugDescription
        } catch {
            return "<invalid>"
        }
    }
}
