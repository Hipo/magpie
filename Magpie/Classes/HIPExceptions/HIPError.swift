//
//  HipoException.swift
//  Magpie
//
//  Created by Karasuluoglu on 20.12.2019.
//

import Foundation

public struct HIPError: Model {
    public let type: String?
    public let detail: HIPErrorDetail?
    public let fallbackMessage: String?
}

extension HIPError {
    public func message(_ path: String...) -> String? {
        return findFieldDetail(at: path)?.messages?.first ?? fallbackMessage
    }

    public func messages(_ path: String...) -> [String]? {
        return findFieldDetail(at: path)?.messages
    }

    private func findFieldDetail(at path: [String]) -> HIPErrorField.Detail? {
        var fieldDetail: HIPErrorField.Detail?

        for (i, fieldName) in path.enumerated() {
            if i == path.startIndex {
                fieldDetail = detail?[fieldName]
            } else {
                fieldDetail = fieldDetail?[fieldName]
            }
        }
        return fieldDetail
    }
}

extension HIPError {
    private enum CodingKeys: String, CodingKey {
        case type
        case detail
        case fallbackMessage = "fallback_message"
    }
}

public struct HIPErrorDetail: Model {
    public var nonFieldMessages: [String]?
    public let fields: [HIPErrorField]

    /// <mark> Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: HIPErrorMessagesCodingKey.self)

        var fields: [HIPErrorField] = []

        for key in container.allKeys {
            if key == HIPErrorMessagesCodingKey.nonFieldMessages() {
                nonFieldMessages = try container.decodeIfPresent([String].self, forKey: key) ?? []
            } else {
                let fieldDetail = try container.decodeIfPresent(HIPErrorField.Detail.self, forKey: key)
                fields.append(HIPErrorField(name: key.stringValue, detail: fieldDetail))
            }
        }
        self.fields = fields
    }

    /// <mark> Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: HIPErrorMessagesCodingKey.self)
        try container.encodeIfPresent(nonFieldMessages, forKey: .nonFieldMessages())

        for field in fields {
            try container.encodeIfPresent(field.detail, forKey: HIPErrorMessagesCodingKey(stringValue: field.name)!)
        }
    }
}

extension HIPErrorDetail {
    public subscript (fieldName: String) -> HIPErrorField.Detail? {
        return fields[fieldName]
    }
}

public struct HIPErrorField: Model {
    public let name: String
    public let detail: Detail?
}

extension HIPErrorField {
    public enum Detail: Model {
        case messages([String])
        case subfields([HIPErrorField])
    }
}

extension HIPErrorField.Detail {
    public var messages: [String]? {
        if case .messages(let someMessages) = self {
            return someMessages
        }
        return nil
    }
    public var subfields: [HIPErrorField]? {
        if case .subfields(let someSubfields) = self {
            return someSubfields
        }
        return nil
    }
}

extension HIPErrorField.Detail {
    /// <mark> Decodable
    public init(from decoder: Decoder) throws {
        do {
            var container = try decoder.unkeyedContainer()
            var messages: [String] = []

            while !container.isAtEnd {
                if let message = try container.decodeIfPresent(String.self) {
                    messages.append(message)
                }
            }
            self = .messages(messages)
        } catch DecodingError.typeMismatch {
            let container = try decoder.container(keyedBy: HIPErrorMessagesCodingKey.self)
            var subfields: [HIPErrorField] = []

            for key in container.allKeys {
                let detail = try container.decodeIfPresent(HIPErrorField.Detail.self, forKey: key)
                subfields.append(HIPErrorField(name: key.stringValue, detail: detail))
            }
            self = .subfields(subfields)
        }
    }

    /// <mark> Encodable
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .messages(let messages):
            var container = encoder.unkeyedContainer()

            for message in messages {
                try container.encode(message)
            }
        case .subfields(let subfields):
            var container = encoder.container(keyedBy: HIPErrorMessagesCodingKey.self)

            for subfield in subfields {
                try container.encodeIfPresent(subfield.detail, forKey: HIPErrorMessagesCodingKey(stringValue: subfield.name)!)
            }
        }
    }
}

extension HIPErrorField.Detail {
    public subscript (subfieldName: String) -> HIPErrorField.Detail? {
        return subfields?[subfieldName]
    }
}

struct HIPErrorMessagesCodingKey: CodingKey, Equatable {
    var stringValue: String
    var intValue: Int? {
        return nil
    }

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        return nil
    }

    static func nonFieldMessages() -> HIPErrorMessagesCodingKey {
        return HIPErrorMessagesCodingKey(stringValue: "non_field_errors")!
    }
}

extension Array where Element == HIPErrorField {
    public subscript (fieldName: String) -> HIPErrorField.Detail? {
        return first { $0.name == fieldName }?.detail
    }
}
