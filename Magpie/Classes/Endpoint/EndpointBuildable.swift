//
//  EndpointBuildable.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 2.04.2019.
//

import Foundation

public protocol EndpointBuildable: AnyObject {
    init(path: Path)

    func context(_ context: EndpointContext) -> Self
    func base(_ base: String) -> Self
    func httpMethod(_ httpMethod: Method) -> Self
    func query<T: Query>(_ query: T, using encodingStrategy: QueryEncodingStrategy?) -> Self
    func httpBody(_ body: Body) -> Self
    func httpBody<T: JSONBody>(_ jsonBody: T, using encodingStrategy: JSONBodyEncodingStrategy?) -> Self
    func httpBody<T: FormBody>(_ formBody: T, using encodingStrategy: FormBodyEncodingStrategy?) -> Self
    func httpHeaders(_ httpHeaders: Headers) -> Self
    func timeout(_ timeout: TimeInterval) -> Self
    func cachePolicy(_ cachePolicy: NSURLRequest.CachePolicy) -> Self

    func build(_ magpie: Magpie) -> EndpointOperatable
    func buildAndSend(_ magpie: Magpie) -> EndpointOperatable
}

public enum EndpointContext {
    public enum Source {
        case data(Data)
        case file(URL)
    }

    case data
    case upload(Source)
}

extension EndpointContext: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .data:
            return "data"
        case .upload(let src):
            return "upload \(src.description)"
        }
    }
}

extension EndpointContext.Source: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .data:
            return "data"
        case .file:
            return "file"
        }
    }
}
