//
//  HTTPHeaders.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 21.10.2018.
//

import Foundation

public enum HTTPHeader {
    case accept(String) /// Accept: {accept}
    case contentType(String) /// Content-Type: {contentType}
    case contentLength(String) /// Content-Length: {contentLength}
    case authorizedToken(String) /// Authorization: Token {token}
    case custom(header: String, value: String?)
}

extension HTTPHeader {
    public var field: String {
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
        return field.hashValue
    }
}

extension HTTPHeader: Equatable {
    public static func == (lhs: HTTPHeader, rhs: HTTPHeader) -> Bool {
        return lhs.field == rhs.field
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
            guard headers.index(of: newHeader) != nil else {
                headers.append(newHeader)
                return
            }
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
