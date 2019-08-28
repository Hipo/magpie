//
//  RequestParameter.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 30.03.2019.
//

import Foundation

public protocol RequestParameter: CustomStringConvertible, CustomDebugStringConvertible {
    typealias Value = RequestParameterValue
    typealias SharedValue = RequestParameterSharedValue.Both
    typealias SharedQueryValue = RequestParameterSharedValue.Query
    typealias SharedJSONBodyValue = RequestParameterSharedValue.JSONBody

    func toString() -> String
    /// <note>
    /// The encoder for query/JSONBody will throw an error if the shared value is requested when the method returns nil.
    /// But it will set null if the value itself returns nil.
    func sharedValue() -> Value?
}

extension RequestParameter {
    public func sharedValue() -> Value? {
        return nil
    }
}

extension RequestParameter where Self: RawRepresentable, Self.RawValue == String {
    public func toString() -> String {
        return rawValue
    }
}

public protocol JSONBodyRequestParameter: RequestParameter, CodingKey {
}

public protocol FormBodyRequestParameter: RequestParameter, CodingKey {
}

public protocol RequestParameterValue: CustomStringConvertible, CustomDebugStringConvertible {
    func queryValue() -> QueryPairValue?
    func bodyValue() -> JSONBodyPairValue?
}

public struct RequestParameterSharedValue {
    public struct Query: RequestParameterValue {
        public var description: String {
            return originalValue?.description ?? "<nil>"
        }

        let originalValue: QueryPairValue?

        public init(_ value: QueryPairValue?) {
            originalValue = value
        }

        public func queryValue() -> QueryPairValue? {
            return originalValue
        }

        public func bodyValue() -> JSONBodyPairValue? {
            return nil
        }
    }

    public struct JSONBody: RequestParameterValue {
        public var description: String {
            return originalValue?.description ?? "<nil>"
        }

        let originalValue: JSONBodyPairValue?

        public init<Value: Encodable>(_ value: Value?) {
            originalValue = value.map { JSONBodyPairValue($0) }
        }

        public func queryValue() -> QueryPairValue? {
            return nil
        }

        public func bodyValue() -> JSONBodyPairValue? {
            return originalValue
        }
    }

    public struct Both: RequestParameterValue {
        public var description: String {
            return """
            query: \(query.description)
            body: \(jsonBody.description)
            """
        }

        let query: Query
        let jsonBody: JSONBody

        public init<Value: QueryPairValue & Encodable>(_ value: Value?) {
            query = Query(value)
            jsonBody = JSONBody(value)
        }

        public func queryValue() -> QueryPairValue? {
            return query.queryValue()
        }

        public func bodyValue() -> JSONBodyPairValue? {
            return jsonBody.bodyValue()
        }
    }
}
