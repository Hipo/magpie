// Copyright © 2021 hipolabs. All rights reserved.

/// <src>
/// https://gist.github.com/krzysztofzablocki/c566408283d623b0092eb8b3267348db

import Foundation
import MacaroonUtils

public protocol ResponseModel: DebugPrintable {
    associatedtype APIModel: JSONModel

    var debugData: Data? { get set }
    var isFault: Bool { get }

    init(_ apiModel: APIModel)
}

extension ResponseModel {
    public var isFault: Bool {
        return false
    }

    public var debugDescription: String {
        return "[\(type(of: self))] \(debugData?.utf8Description ?? "<nil>")"
    }
}

extension ResponseModel {
    public static func decoded(
        _ data: Data
    ) throws -> Self {
        var model = Self(try APIModel.decoded(data))

        debug {
            model.debugData = data
        }

        return model
    }
}

extension Array: ResponseModel where Element: ResponseModel {
    public typealias APIModel = [Element.APIModel]

    public var debugData: Data? {
        get {
            return nil
        }
        set {
        }
    }

    public init(
        _ apiModel: [Element.APIModel]
    ) {
        self.init(apiModel.map(Element.init))
    }
}

public struct NoResponseModel: ResponseModel {
    public var debugData: Data?

    public init(
        _ apiModel: NoJSONModel
    ) {}
}
