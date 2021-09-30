// Copyright © 2021 hipolabs. All rights reserved.

import Foundation
import MacaroonUtils
import SwiftUI

public protocol ResponseModel: DebugPrintable {
    var isFault: Bool { get }

    func encoded() throws -> Data

    static func decoded(
        _ data: Data
    ) throws -> Self
}

public struct NoResponseModel: ResponseModel {
    public var isFault: Bool {
        return false
    }

    public var debugDescription: String {
        return "<nil>"
    }

    public func encoded() throws -> Data {
        return "{}".data(using: .utf8)!
    }

    public static func decoded(
        _ data: Data
    ) throws -> NoResponseModel {
        return NoResponseModel()
    }
}

extension Array: ResponseModel where Element: ResponseModel {
    public var isFault: Bool {
        return false
    }

    public func encoded() throws -> Data where Element: APIModel {
        return try encoded(Element.encodingStrategy)
    }

    public func encoded() throws -> Data where Element: EntityModel {
        let apiModels = map { $0.encode() }
        return try apiModels.encoded(Element.APIModel.encodingStrategy)
    }

    public func encoded() throws -> Data {
        fatalError("Unsupported encoding for elements")
    }

    public static func decoded(
        _ data: Data
    ) throws -> Self where Element: APIModel {
        return try Self.decoded(
            data,
            using: Element.decodingStrategy
        )
    }

    public static func decoded(
        _ data: Data
    ) throws -> Self where Element: EntityModel {
        let apiModels =
            try [Element.APIModel].decoded(
                data,
                using: Element.APIModel.decodingStrategy
            )
        return apiModels.map(Element.init)
    }

    public static func decoded(
        _ data: Data
    ) throws -> Self {
        fatalError("Unsupported decoding for elements")
    }
}
