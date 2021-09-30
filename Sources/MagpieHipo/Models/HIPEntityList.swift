//
//  HIPList.swift
//  Magpie
//
//  Created by Karasuluoglu on 29.07.2020.
//

import Foundation
import MacaroonUtils
import MagpieCore

public final class HIPEntityList<Item: EntityModel>: EntityModel {
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
        self.items = apiModel.results.unwrapMap(Item.init)
    }

    public func encode() -> APIModel {
        return APIModel(
            count: count,
            next: next,
            previous: previous,
            results: items.map { $0.encode() }
        )
    }
}

extension HIPEntityList {
    public struct APIModel: JSONModel {
        public let count: Int?
        public let next: URL?
        public let previous: URL?
        public let results: [Item.APIModel]?

        public static var encodingStrategy: JSONEncodingStrategy {
            return Item.APIModel.encodingStrategy
        }
        public static var decodingStrategy: JSONDecodingStrategy {
            return Item.APIModel.decodingStrategy
        }
    }
}

extension HIPEntityList {
    /// <warning> The right-side list overrides the left one.
    public static func + (
        lhs: HIPEntityList<Item>,
        rhs: HIPEntityList<Item>
    ) -> HIPEntityList<Item> {
        return HIPEntityList(
            count: rhs.count,
            next: rhs.next,
            previous: rhs.previous,
            items: lhs.items + rhs.items
        )
    }

    public static func += (
        lhs: inout HIPEntityList<Item>,
        rhs: HIPEntityList<Item>
    ) {
        lhs = lhs + rhs
    }
}
