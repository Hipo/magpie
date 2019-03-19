//
//  RequestConvertible.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 26.11.2018.
//

import Foundation

protocol RequestConvertible {
    var base: String { get }
    var path: Path { get }
    var httpMethod: HTTPMethod { get }
    var httpHeaders: HTTPHeaders { get }
    var bodyParams: Params? { get }
    var timeout: TimeInterval { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    
    var task: TaskCancellable? { get }
    
    func asUrlRequest() throws -> URLRequest
}

extension RequestConvertible {
    var timeout: TimeInterval {
        return 60.0
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }
    
    func asUrlRequest() throws -> URLRequest {
        guard let baseUrl = URL(string: base) else {
            throw Error.requestEncoding(.emptyOrInvalidBaseURL(base))
        }
        
        var components = URLComponents()
        
        components.scheme = baseUrl.scheme
        components.host = baseUrl.host
        components.path = path.value
        components.port = baseUrl.port
        
        do {
            components.queryItems = try path.queryParams?.asQuery()
        } catch let error {
            throw error
        }
        
        guard let url = components.url else {
            throw Error.requestEncoding(.emptyOrInvalidURL(
                """
                Base: \(base)
                Path: \(path.value)
                Query: \(path.queryParams?.description ?? "null")
                """
                ))
        }
        
        var urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        
        urlRequest.httpShouldHandleCookies = false
        urlRequest.httpMethod = httpMethod.rawValue
        
        do {
            if let body = try bodyParams?.asBody() {
                urlRequest.httpBody = body
                
                let contentLength = HTTPHeader.contentLength("\(body.count)")
                urlRequest.setValue(contentLength.value, forHTTPHeaderField: contentLength.field)
            } else {
                urlRequest.httpBody = nil
            }
        } catch let error {
            throw error
        }
        
        httpHeaders.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.field) }
        
        return urlRequest
    }
}
