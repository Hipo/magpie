//
//  Headers.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 21.10.2018.
//

import Foundation
import MacaroonUtils

public struct Headers {
    fileprivate typealias Table = [String: Header]

    private var table: Table = [:]
    
    init() { }

    init(_ rawHeaders: [AnyHashable: Any]?) {
        guard let someRawHeaders = rawHeaders else { return }

        for rawHeader in someRawHeaders {
            if let key = rawHeader.key as? String {
                let value = rawHeader.value as? String

                switch key {
                case HTTPHeader.accept:
                    table[key] = AcceptHeader(value ?? "")
                case HTTPHeader.acceptEncoding:
                    table[key] = AcceptEncodingHeader(value ?? "")
                case HTTPHeader.acceptLanguage:
                    table[key] = AcceptLanguageHeader(value ?? "")
                case HTTPHeader.authorization:
                    table[key] = AuthorizationHeader(value)
                case HTTPHeader.contentLength:
                    table[key] = ContentLengthHeader(value ?? "")
                case HTTPHeader.contentType:
                    table[key] = ContentTypeHeader(value ?? "")
                default:
                    table[key] = CustomHeader(key: key, value: value)
                }
            }
        }
    }
}

extension Headers {
    public subscript (key: String) -> String? {
        return table[key]?.value
    }

    public mutating func insert(_ newHeader: Header) {
        table[newHeader.key] = newHeader
    }

    @discardableResult
    public mutating func remove(for key: String) -> Header? {
        return table.removeValue(forKey: key)
    }
}

extension Headers {
    /// <note>
    /// The left-side headers will override the right-side headers if they have fields in common.
    public static func >> (lhs: Headers, rhs: Headers) -> Headers {
        var newHeaders = Headers()
        newHeaders.table = lhs.table.merging(rhs.table) { lhsValue, _ in return lhsValue }
        return newHeaders
    }

    /// <note>
    /// The right-side headers will override the left-side headers if they have fields in common.
    public static func << (lhs: Headers, rhs: Headers) -> Headers {
        var newHeaders = Headers()
        newHeaders.table = lhs.table.merging(rhs.table) { _, rhsValue in return rhsValue }
        return newHeaders
    }
}

extension Headers {
    public struct Index {
        fileprivate let wrapped: Table.Index
    }
}

extension Headers: Collection {
    public typealias Element = Header
    
    public var startIndex: Headers.Index {
        return Index(wrapped: table.startIndex)
    }
    public var endIndex: Headers.Index {
        return Index(wrapped: table.endIndex)
    }
    
    public subscript (index: Headers.Index) -> Element {
        return table[index.wrapped].value
    }
    
    public func index(after i: Headers.Index) -> Headers.Index {
        return Index(wrapped: table.index(after: i.wrapped))
    }
}

extension Headers: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Header...) {
        table = Table(elements.map { ($0.key, $0) }) { $1 }
    }
}

extension Headers: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return """
        {
          \(table.map({ $0.value.debugDescription }).joined(separator: ",\n  "))
        }
        """
        }
}

extension Headers.Index: Comparable {
    public static func == (lhs: Headers.Index, rhs: Headers.Index) -> Bool {
        return lhs.wrapped == rhs.wrapped
    }

    public static func < (lhs: Headers.Index, rhs: Headers.Index) -> Bool {
        return  lhs.wrapped < rhs.wrapped
    }
}

public protocol Header: Printable {
    var key: String { get }
    var value: String? { get }
}

extension Header {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "\(key):\(value?.debugDescription ?? "<nil>")"
    }
}

public struct AcceptHeader: Header {
    public let key: String
    public let value: String?

    public init(_ value: String) {
        self.key = HTTPHeader.accept
        self.value = value
    }
}

public struct AcceptJSONHeader: Header {
    public let key: String
    public let value: String?
    
    public init() {
        let base = AcceptHeader("application/json")
        
        self.key = base.key
        self.value = base.value
    }
}

public struct AcceptFormURLEncodedHeader: Header {
    public let key: String
    public var value: String?
    
    public init() {
        let base = AcceptHeader("application/x-www-form-urlencoded")
        
        self.key = base.key
        self.value = base.value
    }
}

public struct AcceptEncodingHeader: Header {
    public let key: String
    public let value: String?

    public init(_ value: String) {
        self.key = HTTPHeader.acceptEncoding
        self.value = value
    }
}

public struct AcceptGZIPEncodingHeader: Header {
    public let key: String
    public var value: String?
    
    public init() {
        let base = AcceptEncodingHeader("gzip;q=1.0, *;q=0.5")

        self.key = base.key
        self.value = base.value
    }
}

public struct AcceptLanguageHeader: Header {
    public let key: String
    public let value: String?

    init(_ value: String) {
        self.key = HTTPHeader.acceptLanguage
        self.value = value
    }
}

public struct AuthorizationHeader: Header {
    public let key: String
    public let value: String?

    public init(_ value: String? = nil) {
        self.key = HTTPHeader.authorization
        self.value = value
    }
}

public struct AuthorizationBasicHeader: Header {
    public let key: String
    public let value: String?
    
    public init(_ value: String?) {
        let basicValue = value.map { "Basic \($0)" }
        let base = AuthorizationHeader(basicValue)
        
        self.key = base.key
        self.value = base.value
    }
}

public struct AuthorizationBearerHeader: Header {
    public let key: String
    public let value: String?
    
    public init(_ value: String?) {
        let bearerValue = value.map { "Bearer \($0)" }
        let base = AuthorizationHeader(bearerValue)
        
        self.key = base.key
        self.value = base.value
    }
}

public struct AuthorizationTokenHeader: Header {
    public let key: String
    public let value: String?
    
    public init(_ value: String?) {
        let tokenValue = value.map { "Token \($0)" }
        let base = AuthorizationHeader(tokenValue)
        
        self.key = base.key
        self.value = base.value
    }
}

public struct ContentLengthHeader: Header {
    public let key: String
    public let value: String?
    
    public init(_ value: String) {
        self.key = HTTPHeader.contentLength
        self.value = value
    }
    
    public init(_ count: Int) {
        self.init(String(count))
    }
}

public struct ContentTypeHeader: Header {
    public let key: String
    public let value: String?

    public init(_ value: String) {
        self.key = HTTPHeader.contentType
        self.value = value
    }
}

public struct ContentTypeJSONHeader: Header {
    public let key: String
    public var value: String?
    
    public init() {
        let base = ContentTypeHeader("application/json")
        
        self.key = base.key
        self.value = base.value
    }
}

public struct ContentTypeFormURLEncodedHeader: Header {
    public let key: String
    public var value: String?
    
    public init() {
        let base = ContentTypeHeader("application/x-www-form-urlencoded")
        
        self.key = base.key
        self.value = base.value
    }
}

public struct CustomHeader: Header {
    public let key: String
    public let value: String?

    public init(
        key: String,
        value: String?
    ) {
        self.key = key
        self.value = value
    }
}

public enum HTTPHeader {
    public static let accept = "Accept"
    public static let acceptEncoding = "Accept-Encoding"
    public static let acceptLanguage = "Accept-Language"
    public static let authorization = "Authorization"
    public static let contentLength = "Content-Length"
    public static let contentType = "Content-Type"
}
