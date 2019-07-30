//
//  Headers.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 21.10.2018.
//

import Foundation

public struct Headers {
    fileprivate typealias EnclosedCollection = [String: Field]

    public enum Field {
        public enum Key: String {
            case accept = "Accept"
            case acceptEncoding = "Accept-Encoding"
            case acceptLanguage = "Accept-Language"
            case contentType = "Content-Type"
            case contentLength = "Content-Length"
            case authorization = "Authorization"
        }

        public enum Value {
            case none
            case some(String)
        }

        case accept(Value)
        case acceptEncoding(Value)
        case acceptLanguage(Value)
        case contentType(Value)
        case contentLength(Value)
        case authorizationToken(Value) /// Authorization: Token {value}
        case bearerToken(Value) /// Authorization: Bearer {value}
        case custom(String, Value) /// {key}: {value}
    }

    /// <note>
    /// Be aware of the additional http headers set by default by Alamofire:
    /// 'Accept-Language' 'User-Agent'
    public static var `default`: Headers {
        return [
            .accept("application/json"),
            .acceptEncoding("gzip;q=1.0, *;q=0.5"),
            .contentType("application/json")
        ]
    }

    private var collection: EnclosedCollection = [:]
    
    init() { }

    init<S: Sequence>(_ sequence: S) where S.Element == Field {
        set(contentsOf: sequence)
    }
}

extension Headers {
    public subscript (key: String) -> String? {
        return collection[key]?.decoded().value
    }

    public subscript (key: Field.Key) -> String? {
        return self[key.rawValue]
    }

    public mutating func set(_ newField: Field) {
        collection[newField.decodedKey()] = newField
    }
    
    public mutating func set<S: Sequence>(contentsOf sequence: S) where S.Element == Field {
        sequence.forEach { set($0) }
    }

    @discardableResult
    public mutating func remove(_ key: String) -> Field? {
        return collection.removeValue(forKey: key)
    }

    @discardableResult
    public mutating func remove(_ key: Field.Key) -> Field? {
        return remove(key.rawValue)
    }

    @discardableResult
    public mutating func remove(_ field: Field) -> Bool {
        return collection.removeValue(forKey: field.decodedKey()) != nil
    }
}

extension Headers {
    /// <note>
    /// The right-side headers will override the left-side headers if they have fields in common.
    public static func + (lhs: Headers, rhs: Headers) -> Headers {
        var newHeaders = Headers()
        lhs.collection.forEach { newHeaders.set($1) }
        rhs.collection.forEach { newHeaders.set($1) }
        return newHeaders
    }
}

extension Headers: Collection {
    public typealias Index = HeaderIndex
    public typealias Element = Field.Output
    
    public var startIndex: Index {
        return HeaderIndex(collection.startIndex)
    }
    
    public var endIndex: Index {
        return HeaderIndex(collection.endIndex)
    }
    
    public subscript (index: Index) -> Element {
        let enclosedIndex = index.enclosedIndex
        let field = collection[enclosedIndex].value
        return field.decoded()
    }
    
    public func index(after i: Index) -> Index {
        let nextEnclosedIndex = collection.index(after: i.enclosedIndex)
        return HeaderIndex(nextEnclosedIndex)
    }
}

extension Headers: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Field

    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(elements)
    }
}

extension Headers: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        let fieldDescriptions = collection.map { $0.value.description }
        return "{\n\t\(fieldDescriptions.joined(separator: ",\n\t"))\n}"
    }
}

extension Headers.Field {
    public typealias Output = (key: String, value: String?)

    public func decodedKey() -> String {
        return decoded().key
    }

    public func decoded() -> Output {
        switch self {
        case .accept(let value):
            return (Key.accept.rawValue, value.decoded())
        case .acceptEncoding(let value):
            return (Key.acceptEncoding.rawValue, value.decoded())
        case .acceptLanguage(let value):
            return (Key.acceptLanguage.rawValue, value.decoded())
        case .contentType(let value):
            return (Key.contentType.rawValue, value.decoded())
        case .contentLength(let value):
            return (Key.contentLength.rawValue, value.decoded())
        case .authorizationToken(let value):
            return (Key.authorization.rawValue, value.decoded().map { "Token \($0)" })
        case .bearerToken(let value):
            return (Key.authorization.rawValue, value.decoded().map { "Bearer \($0)" })
        case .custom(let key, let value):
            return (key, value.decoded())
        }
    }
}

extension Headers.Field: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        let decodedField = decoded()
        return "\(decodedField.key):\(decodedField.value.absoluteDescription)"
    }
}

extension Headers.Field.Value {
    func decoded() -> String? {
        switch self {
        case .none:
            return nil
        case .some(let value):
            return value
        }
    }
}

extension Headers.Field.Value: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .none
    }
}

extension Headers.Field.Value: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public init(stringLiteral value: StringLiteralType) {
        self = .some(value)
    }
}

extension Headers.Field.Value: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return decoded().absoluteDescription
    }
}

public struct HeaderIndex {
    fileprivate typealias EnclosedIndex = Headers.EnclosedCollection.Index

    fileprivate let enclosedIndex: EnclosedIndex

    fileprivate init(_ enclosedIndex: EnclosedIndex) {
        self.enclosedIndex = enclosedIndex
    }
}

extension HeaderIndex: Comparable {
    public static func == (lhs: HeaderIndex, rhs: HeaderIndex) -> Bool {
        return lhs.enclosedIndex == rhs.enclosedIndex
    }

    public static func < (lhs: HeaderIndex, rhs: HeaderIndex) -> Bool {
        return  lhs.enclosedIndex < rhs.enclosedIndex
    }
}
