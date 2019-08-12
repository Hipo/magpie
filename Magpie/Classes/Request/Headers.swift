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
        public enum Key {
            case accept
            case acceptEncoding
            case acceptLanguage
            case authorization
            case contentType
            case contentLength
            case other(String)
        }

        public enum Value {
            case none
            case some(String)
        }

        public enum AuthorizationValue {
            case none
            case token(String) /// Token {value}
            case bearer(String) /// Bearer {value}
            case some(String) /// {value}
        }

        case accept(Value)
        case acceptEncoding(Value)
        case acceptLanguage(Value)
        case authorization(AuthorizationValue)
        case contentType(Value)
        case contentLength(Value)
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
        sequence.forEach { collection[$0.decodedKey()] = $0 }
    }

    init(_ decodedFields: [AnyHashable: Any]) {
        for decodedField in decodedFields {
            if let validKey = decodedField.key as? String {
                self[validKey] = decodedField.value as? String
            }
        }
    }
}

extension Headers {
    public subscript (key: String) -> String? {
        get {
            return collection[key]?.decoded().value
        }
        set {
            set(Field(output: (key, newValue)))
        }
    }

    public subscript (key: Field.Key) -> String? {
        get {
            return self[key.decoded()]
        }
        set {
            self[key.decoded()] = newValue
        }
    }

    public mutating func set(_ newField: Field) {
        collection[newField.decodedKey()] = newField
    }

    @discardableResult
    public mutating func remove(_ key: String) -> Field? {
        return collection.removeValue(forKey: key)
    }

    @discardableResult
    public mutating func remove(_ key: Field.Key) -> Field? {
        return remove(key.decoded())
    }
}

extension Headers {
    /// <note>
    /// The right-side headers will override the left-side headers if they have fields in common.
    public static func + (lhs: Headers, rhs: Headers) -> Headers {
        var newHeaders = Headers()
        lhs.collection.forEach { newHeaders.collection[$0] = $1 }
        rhs.collection.forEach { newHeaders.collection[$0] = $1 }
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

    init(output: Output) {
        let key = Headers.Field.Key(decodedKey: output.key)
        switch key {
        case .accept:
            self = .accept(Headers.Field.Value(decodedValue: output.value))
        case .acceptEncoding:
            self = .acceptEncoding(Headers.Field.Value(decodedValue: output.value))
        case .acceptLanguage:
            self = .acceptLanguage(Headers.Field.Value(decodedValue: output.value))
        case .authorization:
            self = .authorization(Headers.Field.AuthorizationValue(decodedValue: output.value))
        case .contentType:
            self = .contentType(Headers.Field.Value(decodedValue: output.value))
        case .contentLength:
            self = .contentLength(Headers.Field.Value(decodedValue: output.value))
        case .other(let original):
            self = .custom(original, Headers.Field.Value(decodedValue: output.value))
        }
    }

    public func decodedKey() -> String {
        return decoded().key
    }

    public func decoded() -> Output {
        switch self {
        case .accept(let value):
            return (Key.accept.decoded(), value.decoded())
        case .acceptEncoding(let value):
            return (Key.acceptEncoding.decoded(), value.decoded())
        case .acceptLanguage(let value):
            return (Key.acceptLanguage.decoded(), value.decoded())
        case .contentType(let value):
            return (Key.contentType.decoded(), value.decoded())
        case .contentLength(let value):
            return (Key.contentLength.decoded(), value.decoded())
        case .authorization(let value):
            return (Key.authorization.decoded(), value.decoded())
        case .custom(let key, let value):
            return (Key.other(key).decoded(), value.decoded())
        }
    }
}

extension Headers.Field {
    enum AuthorizationPrefix {
        static let token = "Token"
        static let bearer = "Bearer"
    }
}

extension Headers.Field: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        let decodedField = decoded()
        return "\(decodedField.key):\(decodedField.value.absoluteDescription)"
    }
}

extension Headers.Field.Key {
    private enum PredefinedKey {
        static let accept = "Accept"
        static let acceptEncoding = "Accept-Encoding"
        static let acceptLanguage = "Accept-Language"
        static let authorization = "Authorization"
        static let contentType = "Content-Type"
        static let contentLength = "Content-Length"
    }

    init(decodedKey: String) {
        switch decodedKey {
        case PredefinedKey.accept:
            self = .accept
        case PredefinedKey.acceptEncoding:
            self = .acceptEncoding
        case PredefinedKey.acceptLanguage:
            self = .acceptLanguage
        case PredefinedKey.authorization:
            self = .authorization
        case PredefinedKey.contentType:
            self = .contentType
        case PredefinedKey.contentLength:
            self = .contentLength
        default:
            self = .other(decodedKey)
        }
    }

    func decoded() -> String {
        switch self {
        case .accept:
            return PredefinedKey.accept
        case .acceptEncoding:
            return PredefinedKey.acceptEncoding
        case .acceptLanguage:
            return PredefinedKey.acceptLanguage
        case .authorization:
            return PredefinedKey.authorization
        case .contentType:
            return PredefinedKey.contentType
        case .contentLength:
            return PredefinedKey.contentLength
        case .other(let original):
            return original
        }
    }
}

extension Headers.Field.Value {
    init(decodedValue: String?) {
        if let dv = decodedValue {
            self = .some(dv)
        } else {
            self = .none
        }
    }

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
    public init(stringLiteral value: String) {
        self = .some(value)
    }
}

extension Headers.Field.Value: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return decoded().absoluteDescription
    }
}

extension Headers.Field.AuthorizationValue {
    init(decodedValue: String?) {
        if let dv = decodedValue {
            let comps = Components(result: dv)
            switch comps.prefix {
            case .none:
                self = .some(comps.value)
            case .token:
                self = .token(comps.value)
            case .bearer:
                self = .bearer(comps.value)
            }
        } else {
            self = .none
        }
    }

    func decoded() -> String? {
        switch self {
        case .none:
            return nil
        case .token(let value):
            let comps = Components.token(value)
            return comps.result
        case .bearer(let value):
            let comps = Components.bearer(value)
            return comps.result
        case .some(let value):
            let comps = Components(value: value)
            return comps.result
        }
    }
}

extension Headers.Field.AuthorizationValue {
    struct Components {
        enum Prefix: String {
            case none = "none"
            case token = "Token"
            case bearer = "Bearer"
        }

        var result: String {
            switch prefix {
            case .none:
                return value
            default:
                return "\(prefix.rawValue) \(value)"
            }
        }

        let value: String
        let prefix: Prefix

        init(
            value: String,
            prefix: Prefix = .none
        ) {
            self.value = value
            self.prefix = prefix
        }

        init(result: String) {
            if result.hasPrefix(Prefix.token.rawValue) {
                value = result.dropLastWord()
                prefix = Prefix.token
            } else if result.hasPrefix(Prefix.bearer.rawValue) {
                value = result.dropLastWord()
                prefix = Prefix.bearer
            } else {
                value = result
                prefix = .none
            }
        }

        static func token(_ value: String) -> Components {
            return Components(
                value: value,
                prefix: Prefix.token
            )
        }

        static func bearer(_ value: String) -> Components {
            return Components(
                value: value,
                prefix: Prefix.bearer
            )
        }
    }
}

extension Headers.Field.AuthorizationValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .none
    }
}

extension Headers.Field.AuthorizationValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .token(value)
    }
}

extension Headers.Field.AuthorizationValue: CustomStringConvertible, CustomDebugStringConvertible {
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
