//
//  Identifiable.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 15.01.2021.
//

import Foundation

public protocol Identifiable: Hashable {
    associatedtype SomeID: Hashable

    var id: SomeID { get }
}

extension Identifiable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// <note>
    /// To test only the equality of the `id`s. If it returns `true`, then the instances point the
    /// same object.
    /// However, the conforming type should override the default implementation of `==` in order
    /// to test a deeper equality like comparing some/all properties one by one.
    public static func ~= (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs ~= rhs
    }
}
