//
//  HIPList.swift
//  Magpie
//
//  Created by Karasuluoglu on 29.07.2020.
//

import Foundation
import MacaroonUtils
import MagpieCore

public final class HIPList<Item: ResponseModel>: ResponseModel {
    public var debugData: Data?

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
}

extension HIPList {
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

extension HIPList {
    /// <warning> The right-side list overrides the left one.
    public static func + (lhs: HIPList<Item>, rhs: HIPList<Item>) -> HIPList<Item> {
        return HIPList(
            count: rhs.count,
            next: rhs.next,
            previous: rhs.previous,
            items: lhs.items + rhs.items
        )
    }

    public static func += (lhs: inout HIPList<Item>, rhs: HIPList<Item>) {
        lhs = lhs + rhs
    }
}
