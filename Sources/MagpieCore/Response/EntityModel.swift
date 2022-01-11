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

open class ListEntityModel<Element: EntityModel>:
    Collection,
    ResponseModel,
    ExpressibleByArrayLiteral {
    public typealias Index = Int
    
    public var startIndex: Index {
        return items.startIndex
    }
    public var endIndex: Index {
        return items.endIndex
    }
    
    public var isFault: Bool = false
    
    public private(set) var items: [Element] = []
    
    public var debugDescription: String {
        return items.debugDescription
    }
    
    public required init(
        arrayLiteral elements: Element...
    ) {
        items = elements
    }
    
    public required init(
        _ elements: [Element]
    ) {
        items = elements
    }
    
    public required init(
        _ apiModels: [Element.APIModel]
    ) {
        items = apiModels.map(Element.init)
    }
}

extension ListEntityModel {
    public subscript (position: Index) -> Element {
        get { items[position] }
        set { items[position] = newValue }
    }
}

extension ListEntityModel {
    public func index(
        after i: Index
    ) -> Index {
        return items.index(after: i)
    }
}

extension ListEntityModel {
    public func encoded() throws -> Data {
        let apiModels = items.map { $0.encode() }
        return try apiModels.encoded(Element.APIModel.encodingStrategy)
    }
    
    public static func decoded(
        _ data: Data
    ) throws -> Self {
        let apiModels =
            try [Element.APIModel].decoded(
                data,
                using: Element.APIModel.decodingStrategy
            )
        return Self(apiModels)
    }
}
