//
//  Body.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 30.03.2019.
//

import Foundation

public protocol Body: CustomStringConvertible, CustomDebugStringConvertible {
    func encoded() throws -> Data?
}

extension Body {
    public var description: String {
        do {
            guard let data: Data = try encoded() else {
                return "<nil>"
            }
            return data.toString()
        } catch {
            return "<invalid>"
        }
    }

    public func encoded() throws -> Data? {
        return nil
    }
}

extension Data: Body {
    public func encoded() throws -> Data? {
        return self
    }
}

public protocol JSONBody: Encodable, CustomStringConvertible, CustomDebugStringConvertible {
    associatedtype Key: JSONBodyRequestParameter
    typealias Pair = JSONBodyPair<Key>

    func decoded() -> [Pair]?
}

extension JSONBody {
    public var description: String {
        do {
            let encoder = JSONBodyEncoder(jsonBody: self)

            guard let data: Data = try encoder.encode() else {
                return "<nil>"
            }
            return """
            \(data.toString())
            [The actual values may be different considering the JSONBodyEncodingStrategy instance to be used]
            """
        } catch {
            return "<invalid>"
        }
    }

    public func encode(to encoder: Encoder) throws {
        guard let pairs = decoded() else {
            return
        }
        var container = encoder.container(keyedBy: Key.self)

        for pair in pairs {
            try pair.encoded(by: &container)
        }
    }
}

protocol HTTPBodyEncodingStrategy {
}

public struct FormBodyStringEncodingStrategy: HTTPBodyEncodingStrategy {
    let encoding: String.Encoding
}

public struct JSONBodyEncodingStrategy: HTTPBodyEncodingStrategy {
    var date: JSONEncoder.DateEncodingStrategy
    var data: JSONEncoder.DataEncodingStrategy

    public init(
        date: JSONEncoder.DateEncodingStrategy = .deferredToDate,
        data: JSONEncoder.DataEncodingStrategy = .base64
    ) {
        self.date = date
        self.data = data
    }
}

extension JSONBodyEncodingStrategy: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return """
        for date values: \(date)
        for data values: \(data)
        """
    }
}

public struct JSONBodyPair<Key: JSONBodyRequestParameter> {
    public enum EncodingPolicy {
        case useShared /// <note> setAlways the shared value if it is 'Encodable'.
        case setAlways /// <note> Set null if the value is nil.
        case setIfPresent /// <note> Ignore if the value is nil.
        case setIfPresentElseUseShared /// <note> Set the value if it is not nil, or use the shared value if present.
    }

    let key: Key
    let value: JSONBodyPairValue?
    let policy: EncodingPolicy

    public init(key: Key) {
        self.key = key
        self.value = nil
        self.policy = .useShared
    }

    public init<Value: Encodable>(
        key: Key,
        value: Value?,
        policy: EncodingPolicy = .setAlways
    ) {
        self.key = key
        self.policy = policy

        switch policy {
        case .useShared:
            self.value = nil
        default:
            if let v = value {
                self.value = JSONBodyPairValue(v)
            } else {
                self.value = nil
            }
        }
    }
}

extension JSONBodyPair {
    func encoded(by container: inout KeyedEncodingContainer<Key>) throws {
        switch policy {
        case .useShared:
            try sharedEncoded(by: &container)
        case .setAlways:
            if let v = value {
                try container.encode(v, forKey: key)
                return
            }
            try container.encodeNil(forKey: key)
        case .setIfPresent:
            try container.encodeIfPresent(value, forKey: key)
        case .setIfPresentElseUseShared:
            if let v = value {
                try container.encode(v, forKey: key)
                return
            }
            try sharedEncoded(by: &container)
        }
    }

    private func sharedEncoded(by container: inout KeyedEncodingContainer<Key>) throws {
        guard let sharedValue = key.sharedValue() else {
            throw Error.requestEncoding(.invalidSharedJSONBodyPair(key))
        }
        guard let value = sharedValue.bodyValue() else {
            try container.encodeNil(forKey: key)
            return
        }
        try container.encode(value, forKey: key)
    }
}

extension JSONBodyPair: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        if let v = value {
            return "\(key.description):\(v.description)"
        }
        switch policy {
        case .useShared,
             .setIfPresentElseUseShared:
            guard let sharedValue = key.sharedValue() else {
                return "\(key.description):<invalid>"
            }
            return "\(key.description):\(sharedValue.description)"
        case .setAlways:
            return "\(key.description):<nil>"
        case .setIfPresent:
            return "\(key.description):<unavailable>"
        }
    }
}

protocol HTTPBodyEncoding {
    mutating func setIfNeeded(_ encodingStrategy: HTTPBodyEncodingStrategy)

    func encode() throws -> Data?
}

struct BodyEncoder: HTTPBodyEncoding {
    let body: Body

    init(body: Body) {
        self.body = body
    }

    mutating func setIfNeeded(_ encodingStrategy: HTTPBodyEncodingStrategy) { }

    func encode() throws -> Data? {
        return try body.encoded()
    }
}

struct JSONBodyEncoder<T: JSONBody>: HTTPBodyEncoding {
    let jsonBody: T

    private var encodingStrategy: JSONBodyEncodingStrategy?

    init(
        jsonBody: T,
        encodingStrategy: JSONBodyEncodingStrategy? = nil
    ) {
        self.jsonBody = jsonBody
        self.encodingStrategy = encodingStrategy
    }

    mutating func setIfNeeded(_ encodingStrategy: HTTPBodyEncodingStrategy) {
        if self.encodingStrategy == nil {
            self.encodingStrategy = encodingStrategy as? JSONBodyEncodingStrategy
        }
    }

    func encode() throws -> Data? {
        if jsonBody.decoded() == nil {
            return nil
        }
        let encoder = JSONEncoder()

        if let encodingStrategy = encodingStrategy {
            encoder.dateEncodingStrategy = encodingStrategy.date
            encoder.dataEncodingStrategy = encodingStrategy.data
        }
        return try encoder.encode(jsonBody)
    }
}

// MARK: FormBody
public protocol FormBody: Encodable, CustomStringConvertible, CustomDebugStringConvertible {
    associatedtype Key: FormBodyRequestParameter
    typealias Pair = FormBodyPair<Key>
    
    func decoded() -> [Pair]?
}

extension FormBody {
    public var description: String {
        do {
            let encoder = FormBodyEncoder(formBody: self)
            
            guard let data: Data = try encoder.encode() else {
                return "<nil>"
            }
            return """
            \(data.toString())
            [The actual values may be different considering the FormBodyEncodingStrategy instance to be used]
            """
        } catch {
            return "<invalid>"
        }
    }
}

struct FormBodyEncoder<T: FormBody>: HTTPBodyEncoding {
    let formBody: T
    private var stringEncodingStrategy: FormBodyStringEncodingStrategy
    private var encodingStrategy: FormBodyEncodingStrategy
    
    init(
        formBody: T,
        stringEncodingStrategy: FormBodyStringEncodingStrategy? = nil,
        encodingStrategy: FormBodyEncodingStrategy? = nil
        ) {
        
        self.formBody = formBody
        self.stringEncodingStrategy = stringEncodingStrategy ?? FormBodyStringEncodingStrategy(encoding: .utf8)
        self.encodingStrategy = encodingStrategy ?? FormBodyEncodingStrategy()
    }
    
    mutating func setIfNeeded(_ encodingStrategy: HTTPBodyEncodingStrategy) {
        guard let strategy = encodingStrategy as? FormBodyStringEncodingStrategy else {
            return
        }
        
        self.stringEncodingStrategy = strategy
    }
    
    func encode() throws -> Data? {
        guard let pairs = formBody.decoded() else {
            return nil
        }
        
        var keyValuePairs: [String] = []
        
        for pair in pairs {            
            do {
                guard let keyValue = try pair.encoded(using: encodingStrategy)?.first else {
                    continue
                }
                
                keyValuePairs.append("\(keyValue.key)=\(keyValue.value)")
            } catch {
                continue
            }
        }
        
        return keyValuePairs.map { String($0) }
            .joined(separator: "&")
            .data(using: self.stringEncodingStrategy.encoding)
    }
}

public struct FormBodyPair<Key: FormBodyRequestParameter> {
    public enum Value {
        case null
        case some(FormBodyPairValue)
    }
    
    let key: Key
    let value: Value
    
    public init(key: Key, value: Value) {
        self.key = key
        self.value = value
    }
}

extension FormBodyPair {
    func encoded(using encodingStrategy: FormBodyEncodingStrategy) throws -> [String:String]? {
        switch value {
        case .null:
            guard let nullString = encodingStrategy.null.encoded() else {
                return nil
            }
            return [key.toString(): nullString]
        case .some(let someValue):
            return [key.toString(): try someValue.bodyString()]
        }
    }
}

public struct FormBodyEncodingStrategy {
    public enum Null {
        case `default` /// nil
        case empty /// ""
        case dash /// "-"
        case string /// "null"
        case other(String) /// "{string}"
    }
    
    public enum Boolean {
        case `default`
        case number
    }
    
    let null: Null
    let boolean: Boolean
    
    public init(
        null: Null = .default,
        boolean: Boolean = .default
        ) {
        self.null = null
        self.boolean = boolean
    }
}

extension FormBodyEncodingStrategy: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return """
        for null values: \(null.description)
        for boolean values: \(boolean.description)
        """
    }
}

extension FormBodyEncodingStrategy.Null {
    func encoded() -> String? {
        switch self {
        case .default:
            return nil
        case .empty:
            return ""
        case .dash:
            return "-"
        case .string:
            return "null"
        case .other(let string):
            return string
        }
    }
}

extension FormBodyEncodingStrategy.Null: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return encoded().absoluteDescription
    }
}

extension FormBodyEncodingStrategy.Boolean {
    func encoded(boolean: Bool) -> String {
        switch self {
        case .default:
            return boolean ? "true" : "false"
        case .number:
            return boolean ? "1" : "0"
        }
    }
}

extension FormBodyEncodingStrategy.Boolean: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "\(encoded(boolean: true))/\(encoded(boolean: false))"
    }
}

public protocol FormBodyPairValue: CustomStringConvertible, CustomDebugStringConvertible {
    func bodyString() throws -> String
}

extension FormBodyPairValue {
    public var description: String {
        do {
            return try bodyString()
        } catch {
            return "<invalid>"
        }
    }
}

extension String: FormBodyPairValue {
    public func bodyString() throws -> String {
        return self
    }
}

extension Int: FormBodyPairValue {
    public func bodyString() throws -> String {
        return String(self)
    }
}

extension Float: FormBodyPairValue {
    public func bodyString() throws -> String {
        return String(self)
    }
}

extension Double: FormBodyPairValue {
    public func bodyString() throws -> String {
        return String(self)
    }
}

extension Bool: FormBodyPairValue {
    public func bodyString() throws -> String {
        return queryString(for: .default)
    }
    
    func bodyString(for strategy: FormBodyEncodingStrategy.Boolean) -> String {
        return strategy.encoded(boolean: self)
    }
}

extension Array: FormBodyPairValue where Element: FormBodyPairValue {
    public func bodyString() throws -> String {
        let values = try self.map { try $0.bodyString() }
        return "[\(values.joined(separator: ","))]"
    }
}

extension Dictionary: FormBodyPairValue where Key: RequestParameter, Value: FormBodyPairValue {
    public func bodyString() throws -> String {
        let values = try self.map { "\($0.key.toString()):\(try $0.value.bodyString())" }
        return "{\(values.joined(separator: ","))}"
    }
}
