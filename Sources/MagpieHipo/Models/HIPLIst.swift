// Copyright © 2021 hipolabs. All rights reserved.

import Foundation
import MacaroonUtils
import MagpieCore

public final class HIPList<Item: APIModel>: EntityModel {
    public let count: Int
    public let next: URL?
    public let previous: URL?
    public let items: [Item]

    public init(
        count: Int,
        next: URL?,
        previous: URL?,
        items: [Item]
    ) {
        self.count = count
        self.next = next
        self.previous = previous
        self.items = items
    }

    public init(
        _ apiModel: APIModel
    ) {
        self.count = apiModel.count ?? 0
        self.next = apiModel.next
        self.previous = apiModel.previous
        self.items = apiModel.results ?? []
    }

    public func encode() -> APIModel {
        return APIModel(
            count: count,
            next: next,
            previous: previous,
            results: items
        )
    }
}

extension HIPList {
    public struct APIModel: JSONModel {
        public let count: Int?
        public let next: URL?
        public let previous: URL?
        public let results: [Item]?

        public static var encodingStrategy: JSONEncodingStrategy {
            return Item.encodingStrategy
        }
        public static var decodingStrategy: JSONDecodingStrategy {
            return Item.decodingStrategy
        }
    }
}

extension HIPList {
    /// <warning> The right-side list overrides the left one.
    public static func + (
        lhs: HIPList<Item>,
        rhs: HIPList<Item>
    ) -> HIPList<Item> {
        return HIPList(
            count: rhs.count,
            next: rhs.next,
            previous: rhs.previous,
            items: lhs.items + rhs.items
        )
    }

    public static func += (
        lhs: inout HIPList<Item>,
        rhs: HIPList<Item>
    ) {
        lhs = lhs + rhs
    }
}
