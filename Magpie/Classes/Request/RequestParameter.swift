//
//  RequestParameter.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 30.03.2019.
//

import Foundation

public protocol RequestParameter: CustomStringConvertible, CustomDebugStringConvertible {
    func toString() -> String
    func sharedValue() -> RequestParameterValue?
}

extension RequestParameter {
    public func sharedValue() -> RequestParameterValue? {
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

public protocol RequestParameterValue: CustomStringConvertible, CustomDebugStringConvertible {
    func asQuery() -> QueryPairValue?
    func asJSONBody() -> JSONBodyPairValue?
}

public struct RequestParameterSharedValue: RequestParameterValue {
    private var queryValue: QueryPairValue?
    private var jsonBodyValue: JSONBodyPairValue?
    
    public func asQuery() -> QueryPairValue? {
        return queryValue
    }
    
    public func asJSONBody() -> JSONBodyPairValue? {
        return jsonBodyValue
    }
    
    private init(
        queryValue: QueryPairValue?,
        jsonBodyValue: JSONBodyPairValue?
    ) {
        self.queryValue = queryValue
        self.jsonBodyValue = jsonBodyValue
    }
    
    public static func forQuery(_ value: QueryPairValue?) -> RequestParameterSharedValue {
        return RequestParameterSharedValue(queryValue: value, jsonBodyValue: nil)
    }
    
    public static func forJSONBody<T: Encodable>(_ value: T?) -> RequestParameterSharedValue {
        return RequestParameterSharedValue(queryValue: nil, jsonBodyValue: JSONBodyPairValue(value, .setIfPresent))
    }
    
    public static func forAll<T: Encodable & QueryPairValue>(_ value: T?) -> RequestParameterSharedValue {
        return RequestParameterSharedValue(queryValue: value, jsonBodyValue: JSONBodyPairValue(value, .setIfPresent))
    }
}

extension RequestParameterSharedValue {
    public var description: String {
        return """
        query: \(queryValue?.description ?? "<nil>")
        body: \(jsonBodyValue?.description ?? "<nil>")
        """
    }
}
