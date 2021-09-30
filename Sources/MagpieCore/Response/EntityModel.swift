// Copyright © 2021 hipolabs. All rights reserved.

/// <src>
/// https://gist.github.com/krzysztofzablocki/c566408283d623b0092eb8b3267348db

import Foundation
import MacaroonUtils

public protocol EntityModel: ResponseModel {
    associatedtype APIModel: JSONModel

    init(
        _ apiModel: APIModel
    )

    func encode() -> APIModel
}

extension EntityModel {
    public var isFault: Bool {
        return false
    }

    public var debugDescription: String {
        let apiModel = encode()
        return "[\(type(of: self))] \(apiModel.debugDescription)"
    }

    public func encoded() throws -> Data {
        let apiModel = encode()
        return try apiModel.encoded()
    }

    public static func decoded(
        _ data: Data
    ) throws -> Self {
        return Self(try APIModel.decoded(data))
    }
}
