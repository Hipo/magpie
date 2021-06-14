//
//  HIPList.swift
//  Magpie
//
//  Created by Karasuluoglu on 29.07.2020.
//

import Foundation
import MacaroonUtils

open class HIPList<Item: JSONModel>: JSONModel {
    public let count: Int
    public let next: URL?
    public let previous: URL?
    public let results: [Item]

    open class var encodingStrategy: JSONEncodingStrategy {
        return Item.encodingStrategy
    }
    open class var decodingStrategy: JSONDecodingStrategy {
        return Item.decodingStrategy
    }

    public init(
        count: Int,
        next: URL?,
        previous: URL?,
        results: [Item]
    ) {
        self.count = count
        self.next = next
        self.previous = previous
        self.results = results
    }

    /// <mark> Decodable
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        count = try container.decodeIfPresent(Int.self, forKey: .count) ?? 0
        next = try container.decodeIfPresent(URL.self, forKey: .next)
        previous = try container.decodeIfPresent(URL.self, forKey: .previous)
        results = try container.decodeIfPresent([Item].self, forKey: .results) ?? []
    }

    /// <mark> Encodable
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(count, forKey: .count)
        try container.encodeIfPresent(next, forKey: .next)
        try container.encodeIfPresent(previous, forKey: .previous)
        try container.encode(results, forKey: .results)
    }
}

extension HIPList {
    /// <warning> The right-side list overrides the left one.
    public static func + (lhs: HIPList<Item>, rhs: HIPList<Item>) -> HIPList<Item> {
        return HIPList(
            count: rhs.count,
            next: rhs.next,
            previous: rhs.previous,
            results: lhs.results + rhs.results
        )
    }

    public static func += (lhs: inout HIPList<Item>, rhs: HIPList<Item>) {
        lhs = lhs + rhs
    }
}

extension HIPList {
    enum CodingKeys: String, CodingKey {
        case count
        case next
        case previous
        case results
    }
}
