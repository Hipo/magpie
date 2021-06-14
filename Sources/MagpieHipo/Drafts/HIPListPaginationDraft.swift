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

    public init(url: URL?) {
        guard let url = url else {
            queryParams = []
            return
        }
        let components =  URLComponents(url: url, resolvingAgainstBaseURL: false)
        queryParams = components?.queryItems ?? []
    }

    public func encoded() throws -> [URLQueryItem] {
        return queryParams
    }
}
