//
//  Request+Components.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 10.10.2018.
//

import Foundation

/// HTTP method
public enum HTTPMethod: String {
    case get = "GET"
    case head = "HEAD"
    case delete = "DELETE"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
}

/// HTTP headers
public enum HTTPHeader {
    case accept(String) /// Accept: {accept}
    case contentType(String) /// Content-Type: {contentType}
    case contentLength(String) /// Content-Length: {contentLength}
    case authorizedToken(String) /// Authorization: Token {token}
    case custom(header: String, value: String?)
}

extension HTTPHeader {
    public var header: String {
        switch self {
        case .accept:
            return "Accept"
        case .contentType:
            return "Content-Type"
        case .contentLength:
            return "Content-Length"
        case .authorizedToken:
            return "Authorization"
        case .custom(let header, _):
            return header
        }
    }
    
    public var value: String? {
        switch self {
        case .accept(let value),
             .contentType(let value),
             .contentLength(let value):
            return value
        case .authorizedToken(let token):
            return "Token \(token)"
        case .custom(_, let value):
            return value
        }
    }
}

extension HTTPHeader: Hashable {
    public var hashValue: Int {
        return header.hashValue
    }
}

extension HTTPHeader: Equatable {
    public static func == (lhs: HTTPHeader, rhs: HTTPHeader) -> Bool {
        return lhs.header == rhs.header
    }
}

public struct HTTPHeaders {
    public typealias Header = HTTPHeader
    
    private var headers: [HTTPHeader] = []
    
    init() {
    }
    
    init<S>(_ sequence: S) where S: Sequence, S.Element == Header {
        for element in sequence {
            append(element)
        }
    }
    
    static func defaults() -> HTTPHeaders {
        return [
            .accept("application/json"),
            .contentType("application/json")
        ]
    }
}

extension HTTPHeaders {
    public mutating func append(_ newElement: Header) {
        headers.append(newElement)
    }
    
    public mutating func append<S>(contentsOf sequence: S) where S: Sequence, S.Element == Header {
        headers.append(contentsOf: sequence)
    }

    public mutating func merge(with newHeaders: HTTPHeaders) {
        newHeaders.forEach { (newHeader) in
            guard let foundIdx = headers.index(of: newHeader) else {
                headers.append(newHeader)
                return
            }
            headers[foundIdx] = newHeader
        }
    }
}

extension HTTPHeaders: Collection {
    public typealias Index = Int
    public typealias Element = Header
    
    public var startIndex: Index {
        return headers.startIndex
    }
    
    public var endIndex: Index {
        return headers.endIndex
    }
    
    public subscript (index: Index) -> Element {
        return headers[index]
    }
    
    public func index(after i: Index) -> Index {
        return headers.index(after: i)
    }
}

extension HTTPHeaders: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Header
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(elements)
    }
}

extension HTTPHeaders: CustomStringConvertible {
    public var description: String {
        return "\(headers)"
    }
}

/// path + query
public struct Path {
    let value: String
    var queryParams: Params?
    
    public init(_ path: String) {
        self.value = path
    }
    
    public mutating func with(query queryParams: Params?) {
        self.queryParams = queryParams
    }
}

extension Path: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self = Path(value)
    }
}

/// query & body parameters
public protocol ParamsPairValue {
    func asQueryItemValue() -> String?
}

extension ParamsPairValue {
    public func asQueryItemValue() -> String? {
        return nil
    }
}

extension String: ParamsPairValue {
    public func asQueryItemValue() -> String? {
        return self
    }
}

extension Int: ParamsPairValue {
    public func asQueryItemValue() -> String? {
        return "\(self)"
    }
}

extension Double: ParamsPairValue {
    public func asQueryItemValue() -> String? {
        return "\(self)"
    }
}

extension Float: ParamsPairValue {
    public func asQueryItemValue() -> String? {
        return "\(self)"
    }
}

extension Bool: ParamsPairValue {
    public func asQueryItemValue() -> String? {
        return self ? "true" : "false"
    }
}

extension Array: ParamsPairValue where Element: ParamsPairValue {
}

extension Dictionary: ParamsPairValue where Key == String, Value: ParamsPairValue {
}

public protocol ParamsPairKey {
    var description: String { get }
    var defaultValue: ParamsPairValue? { get }
}

public enum ParamsPair {
    case `default`(key: ParamsPairKey)
    case custom(key: ParamsPairKey, value: ParamsPairValue)
}

public struct Params {
    public typealias Pair = ParamsPair
    
    private var pairs: [Pair] = []
    
    init() {
    }
    
    init<S>(_ sequence: S) where S: Sequence, S.Element == Pair {
        for element in sequence {
            append(element)
        }
    }
}

extension Params {
    public mutating func append(_ newElement: Pair) {
        pairs.append(newElement)
    }
    
    public mutating func append<S>(contentsOf sequence: S) where S: Sequence, S.Element == Pair {
        pairs.append(contentsOf: sequence)
    }
    
    public func asQuery() throws -> [URLQueryItem]? {
        if pairs.isEmpty {
            return nil
        }
        
        do {
            return try pairs.map { (pair) in
                let key: ParamsPairKey
                let value: ParamsPairValue?
                
                switch pair {
                case .default(let aKey):
                    key = aKey
                    value = aKey.defaultValue
                case .custom(let aKey, let aValue):
                    key = aKey
                    value = aValue
                }
                
                guard let theValue = value?.asQueryItemValue() else {
                    throw Error.requestEncoding(.invalidURLQuery(self))
                }
                
                return URLQueryItem(name: key.description, value: theValue)
            }
        } catch let exp {
            throw exp
        }
    }
    
    public func asBody() throws -> Data? {
        if pairs.isEmpty {
            return nil
        }
        
        let pairsJSON: [String: ParamsPairValue] = pairs.reduce([:]) { (JSON, pair) in
            let key: ParamsPairKey
            let value: ParamsPairValue?
            
            switch pair {
            case .default(let aKey):
                key = aKey
                value = aKey.defaultValue
            case .custom(let aKey, let aValue):
                key = aKey
                value = aValue
            }
            
            guard let theValue = value else {
                return JSON
            }
            
            var mutableJSON = JSON
            mutableJSON[key.description] = theValue
            
            return mutableJSON
        }
        
        do {
            return try JSONSerialization.data(withJSONObject: pairsJSON)
        } catch let exp {
            throw Error.requestEncoding(.invalidHTTPBody(self, exp))
        }
    }
}

extension Params: Collection {
    public typealias Index = Int
    public typealias Element = Pair
    
    public var startIndex: Index {
        return pairs.startIndex
    }
    
    public var endIndex: Index {
        return pairs.endIndex
    }
    
    public subscript (index: Index) -> Element {
        return pairs[index]
    }
    
    public func index(after i: Index) -> Index {
        return pairs.index(after: i)
    }
}

extension Params: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Pair
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(elements)
    }
}

extension Params: CustomStringConvertible {
    public var description: String {
        return "\(pairs)"
    }
}
