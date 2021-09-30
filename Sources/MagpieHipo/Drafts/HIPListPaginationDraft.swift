//
//  HIPListPaginationDraft.swift
//  Magpie
//
//  Created by Karasuluoglu on 29.07.2020.
//

import Foundation
import MagpieCore

public struct HIPListPaginationDraft: Query {
    public let queryParams: [URLQueryItem]

    public init(
        url: URL?
    ) {
        if let url = url {
            let components =  URLComponents(url: url, resolvingAgainstBaseURL: false)
            queryParams = components?.queryItems ?? []
        } else {
            queryParams = []
        }
    }

    public func encoded() throws -> [URLQueryItem] {
        return queryParams
    }
}
