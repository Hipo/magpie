//
//  Request+Components.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 10.10.2018.
//

import Foundation

public protocol ParamsPairKey {
    var description: String { get }
    var defaultValue: ParamsPairValue? { get }
}

extension ParamsPairKey {
    var defaultValue: ParamsPairValue? {
        return nil
    }
}

public protocol ParamsPairValue {
    func asQueryItemValue() -> String?
    func asBodyElementValue() -> Any
}

extension ParamsPairValue {
    public func asQueryItemValue() -> String? {
        return nil
    }
    
    public func asBodyElementValue() -> Any {
        return self
    }
}

public typealias AnyParamsPairValue = Any & ParamsPairValue

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

extension Array: ParamsPairValue where Element == AnyParamsPairValue {
    public func asQueryItemValue() -> String? {
        var queryItemsValues: [String] = []
        
        for value in self {
            guard let theValue = value.asQueryItemValue() else {
                return nil
            }
            queryItemsValues.append(theValue)
        }
        
        return "[" + queryItemsValues.joined(separator: ",") + "]"
    }
    
    public func asBodyElementValue() -> Any {
        return map { $0.asBodyElementValue() }
    }
}

extension Dictionary: ParamsPairValue where Key: ParamsPairKey, Value == AnyParamsPairValue {
    public func asQueryItemValue() -> String? {
        var queryItemValues: [String] = []
        
        for (key, value) in self {
            guard let theValue = value.asQueryItemValue() else {
                return nil
            }
            queryItemValues.append("\(key.description):\(theValue)")
        }
        
        return "{" + queryItemValues.joined(separator: ",") + "}"
    }
    
    public func asBodyElementValue() -> Any {
        var bodyElementValues: [String: Any] = [:]
        forEach { bodyElementValues[$0.key.description] = $0.value.asBodyElementValue() }
        return bodyElementValues
    }
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
    }
    
    public func asBody() throws -> Data? {
        if pairs.isEmpty {
            return nil
        }
        
        let pairsJSON: [String: Any] = try pairs.reduce([:]) { (JSON, pair) in
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
            
            guard let theValue = value?.asBodyElementValue() else {
                throw Error.requestEncoding(.invalidHTTPBody(self, nil))
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
