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

extension Array: ResponseModel where Element: APIModel {
    public var isFault: Bool {
        return false
    }

    public func encoded() throws -> Data {
        return try encoded(Element.encodingStrategy)
    }

    public static func decoded(
        _ data: Data
    ) throws -> Self {
        return try Self.decoded(
            data,
            using: Element.decodingStrategy
        )
    }
}
