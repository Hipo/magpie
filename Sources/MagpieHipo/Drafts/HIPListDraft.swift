//
//  HIPListDraft.swift
//  Pods
//
//  Created by Karasuluoglu on 28.12.2020.
//

import Foundation
import MagpieCore

public enum HIPListDraft<ListDraft: Query>: Query {
    case list(ListDraft)
    case pagination(HIPListPaginationDraft)

    public func encoded() throws -> [URLQueryItem] {
        switch self {
        case .list(let listDraft):
            return try listDraft.encoded()
        case .pagination(let paginationDraft):
            return try paginationDraft.encoded()
        }
    }
}
