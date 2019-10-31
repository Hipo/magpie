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
    public func encoded() throws -> Data? {
        return nil
    }
}

extension Body {
    public var description: String {
        do {
            if let data: Data = try encoded() {
                return data.toString()
            }
            return "<nil>"
        } catch {
            return "<invalid>"
        }
    }
}

extension Data: Body {
    public func encoded() throws -> Data? {
        return self
    }
}

public protocol JSONBody: Encodable, CustomStringConvertible, CustomDebugStringConvertible {
}

extension JSONBody {
    public var description: String {
        do {
            let encoder = JSONBodyEncoder(encodingBody: self)
            
            if let data: Data = try encoder.encode() {
                return """
                \(data.toString())
                [The actual values may be different considering the JSONBodyEncodingStrategy instance to be used]
                """
            }
            return "<nil>"
        } catch {
            return "<invalid>"
        }
    }
}

public protocol JSONSingleValueBody: JSONBody {
    func decoded() -> JSONBodyPairValue
}

extension JSONSingleValueBody {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try decoded().encoded(by: &container)
    }
}

extension JSONSingleValueBody {
    public var description: String {
        return decoded().description
    }
}

public protocol JSONUnkeyedBody: JSONBody {
    associatedtype Key: JSONBodyRequestParameter
    typealias Pair = JSONBodyPair<Key>
    
    func decoded() -> [[Pair]]?
}

extension JSONUnkeyedBody {
    public func encode(to encoder: Encoder) throws {
        if let decodedPairs = decoded() {
            var container = encoder.unkeyedContainer()
            
            for pairs in decodedPairs {
                var pairsContainer = container.nestedContainer(keyedBy: Key.self)
                
                for pair in pairs {
                    try pair.encoded(by: &pairsContainer)
                }
            }
        }
    }
}

public protocol JSONKeyedBody: JSONBody {
    associatedtype Key: JSONBodyRequestParameter
    typealias Pair = JSONBodyPair<Key>

    func decoded() -> [Pair]?
}

extension JSONKeyedBody {
    public func encode(to encoder: Encoder) throws {
        if let decodedPairs = decoded() {
            var container = encoder.container(keyedBy: Key.self)
            
            for pair in decodedPairs {
                try pair.encoded(by: &container)
            }
        }
    }
}

protocol BodyEncodingStrategy {
}

public struct JSONBodyEncodingStrategy: BodyEncodingStrategy {
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
        Encoding strategy
        for date values: \(date)
        for data values: \(data)
        """
    }
}

public struct JSONBodyPair<Key: JSONBodyRequestParameter> {
    public enum KeyedEncodingPolicy {
        case setAlways /// <note> Set null if the value is nil.
        case setIfPresent /// <note> Ignore if the value is nil.
        case setIfPresentElseUseShared /// <note> Set the value if it is not nil, or use the shared value if present.
    }
    
    let key: Key
    let value: JSONBodyPairValue

    public init(key: Key) {
        self.key = key
        
        if let sharedValue = key.sharedValue()?.asJSONBody() {
            self.value = sharedValue
        } else {
            let nilValue: String? = nil
            self.value = JSONBodyPairValue(nilValue, .setIfPresent)
        }
    }

    public init<EncodingValue: Encodable>(
        key: Key,
        value: EncodingValue?,
        policy: KeyedEncodingPolicy = .setAlways
    ) {
        self.key = key

        switch policy {
        case .setAlways:
            self.value = JSONBodyPairValue(value, .setAlways)
        case .setIfPresent:
            self.value = JSONBodyPairValue(value, .setIfPresent)
        case .setIfPresentElseUseShared:
            if let v = value {
                self.value = JSONBodyPairValue(v, .setAlways)
            } else if let sharedValue = key.sharedValue()?.asJSONBody() {
                self.value = sharedValue
            } else {
                let nilValue: String? = nil
                self.value = JSONBodyPairValue(nilValue, .setIfPresent)
            }
        }
    }
}

extension JSONBodyPair {
    func encoded(by container: inout KeyedEncodingContainer<Key>) throws {
        try value.encoded(for: key, by: &container)
    }
}

extension JSONBodyPair: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "\(key.description):\(value.description)"
    }
}

public struct JSONBodyPairValue {
    public enum EncodingPolicy {
        case setAlways /// <note> Set null if the value is nil.
        case setIfPresent /// <note> Ignore if the value is nil.
    }
    
    let wrapped: AnyEncodable?
    let policy: EncodingPolicy
    
    init(policy: EncodingPolicy) {
        self.wrapped = nil
        self.policy = policy
    }
    
    init<EncodingValue: Encodable>(
        _ value: EncodingValue?,
        _ policy: EncodingPolicy
    ) {
        if let v = value {
            self.wrapped = AnyEncodable(v)
        } else {
            self.wrapped = nil
        }
        self.policy = policy
    }
}

extension JSONBodyPairValue {
    func encoded(by container: inout SingleValueEncodingContainer) throws {
        switch policy {
        case .setAlways:
            try container.encode(wrapped)
        case .setIfPresent:
            if let someWrapped = wrapped {
                try container.encode(someWrapped)
            }
        }
    }
    
    func encoded(by container: inout UnkeyedEncodingContainer) throws {
        switch policy {
        case .setAlways:
            try container.encode(wrapped)
        case .setIfPresent:
            if let someWrapped = wrapped {
                try container.encode(someWrapped)
            }
        }
    }
    
    func encoded<T: JSONBodyRequestParameter>(for key: T, by container: inout KeyedEncodingContainer<T>) throws {
        switch policy {
        case .setAlways:
            if let someWrapped = wrapped {
                try container.encode(someWrapped, forKey: key)
            } else {
                try container.encodeNil(forKey: key)
            }
        case .setIfPresent:
            if let someWrapped = wrapped {
                try container.encode(someWrapped, forKey: key)
            }
        }
    }
}

extension JSONBodyPairValue: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "\(wrapped?.description ?? "<nil>")[\(policy.description)]"
    }
}

extension JSONBodyPairValue.EncodingPolicy: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .setAlways:
            return "set always"
        case .setIfPresent:
            return "set if present"
        }
    }
}

protocol BodyEncoding {
    mutating func setIfNeeded(_ encodingStrategy: BodyEncodingStrategy)

    func encode() throws -> Data?
}

struct BodyEncoder: BodyEncoding {
    let body: Body

    init(body: Body) {
        self.body = body
    }

    mutating func setIfNeeded(_ encodingStrategy: BodyEncodingStrategy) { }

    func encode() throws -> Data? {
        return try body.encoded()
    }
}

struct JSONBodyEncoder<Encoding: Encodable>: BodyEncoding {
    let encodingBody: Encoding

    private var encodingStrategy: JSONBodyEncodingStrategy?

    init(
        encodingBody: Encoding,
        encodingStrategy: JSONBodyEncodingStrategy? = nil
    ) {
        self.encodingBody = encodingBody
        self.encodingStrategy = encodingStrategy
    }

    mutating func setIfNeeded(_ encodingStrategy: BodyEncodingStrategy) {
        if self.encodingStrategy == nil {
            self.encodingStrategy = encodingStrategy as? JSONBodyEncodingStrategy
        }
    }

    func encode() throws -> Data? {
        let encoder = JSONEncoder()

        if let encodingStrategy = encodingStrategy {
            encoder.dateEncodingStrategy = encodingStrategy.date
            encoder.dataEncodingStrategy = encodingStrategy.data
        }
        return try encoder.encode(encodingBody)
    }
}
