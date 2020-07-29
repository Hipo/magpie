//
//  HIPError.swift
//  Magpie
//
//  Created by Karasuluoglu on 29.07.2020.
//

import Foundation

public enum HIPError<AppError: Error> {
    case inapp(AppError)
    case clientUnauthorized(HIPAPIError?)
    case clientForbidden(HIPAPIError?)
    case clientNotFound(HIPAPIError?)
    case client(HTTPError, HIPAPIError?)
    case network(NetworkError)
    case server(HTTPError)
    case unexpected(APIError)
}

public struct NoAppError: Error { }
