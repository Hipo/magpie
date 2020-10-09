//
//  HIPError.swift
//  Magpie
//
//  Created by Karasuluoglu on 29.07.2020.
//

import Foundation

public enum HIPError: Error {
    case inapp(Error)
    case client(HTTPError, HIPAPIError?)
    case server(HTTPError)
    case network(NetworkError)
    case unexpected(APIError)

    public init(
        apiError: APIError,
        apiErrorDetail: HIPAPIError? = nil
    ) {
        if let httpError = apiError as? HTTPError {
            if httpError.isClient {
                self = .client(httpError, apiErrorDetail)
                return
            }
            if httpError.isServer {
                self = .server(httpError)
                return
            }
        }
        if let networkError = apiError as? NetworkError {
            self = .network(networkError)
            return
        }
        self = .unexpected(apiError)
    }
}
