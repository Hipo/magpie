//
//  Model.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Foundation

public protocol Model: Codable, CustomStringConvertible, CustomDebugStringConvertible {
}

extension Model {
    public var description: String {
        do {
            let data = try encoded()
            return """
            \(type(of: self))
            \(data.toString())
            [The actual values may be different considering the ModelDecodingStrategy instance to be used]
            """
        } catch {
            return "<invalid>"
        }
    }
}

extension Model {
    static func decoded(from data: Data, using decodingStrategy: ModelDecodingStrategy? = nil) throws -> Self {
        let decoder = JSONDecoder()

        if let decodingStrategy = decodingStrategy {
            decoder.keyDecodingStrategy = decodingStrategy.key
            decoder.dateDecodingStrategy = decodingStrategy.date
            decoder.dataDecodingStrategy = decodingStrategy.data
        }
        return try decoder.decode(Self.self, from: data)
    }

    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }
}

extension Array: Model where Element: Model {
}

extension Dictionary: Model where Key == String, Value: Model {
}

public struct ModelDecodingStrategy {
    var key: JSONDecoder.KeyDecodingStrategy
    var date: JSONDecoder.DateDecodingStrategy
    var data: JSONDecoder.DataDecodingStrategy

    public init(
        key: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        date: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        data: JSONDecoder.DataDecodingStrategy = .base64
    ) {
        self.key = key
        self.date = date
        self.data = data
    }
}

extension ModelDecodingStrategy: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return """
        for keys: \(key)
        for date values: \(date)
        for data values: \(data)
        """
    }
}
