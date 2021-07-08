//
//  HIPError.swift
//  Magpie
//
//  Created by Karasuluoglu on 29.07.2020.
//

import Foundation
import MacaroonUtils
import MagpieCore
import MagpieExceptions

public enum HIPNetworkError<
    APIErrorDetail: DebugPrintable
>: Error,
   Hashable,
   DebugPrintable {
    case client(HTTPError, APIErrorDetail?)
    case server(HTTPError, APIErrorDetail?)
    case connection(ConnectionError)
    case unexpected(APIError)

    public init(
        apiError: APIError,
        apiErrorDetail: APIErrorDetail? = nil
    ) {
        if let httpError = apiError as? HTTPError {
            if httpError.isClient {
                self = .client(httpError, apiErrorDetail)
                return
            }
            if httpError.isServer {
                self = .server(httpError, apiErrorDetail)
                return
            }
        }
        if let connectionError = apiError as? ConnectionError {
            self = .connection(connectionError)
            return
        }
        self = .unexpected(apiError)
    }
}

extension HIPNetworkError {
    public var debugDescription: String {
        switch self {
        case .client(let httpError, let apiErrorDetail):
            return """
            Client
            \(httpError.debugDescription)
            \(apiErrorDetail.debugDescription)
            """
        case .server(let httpError, let apiErrorDetail):
            return """
            Server
            \(httpError.debugDescription)
            \(apiErrorDetail.debugDescription)
            """
        case .connection(let connectionError):
            return """
            Connection
            \(connectionError.debugDescription)
            """
        case .unexpected(let apiError):
            return """
            Unexpected
            \(apiError.debugDescription)
            """
        }
    }
}

extension HIPNetworkError {
    public func hash(
        into hasher: inout Hasher
    ) {
        switch self {
        case .client(let httpError, _),
             .server(let httpError, _):
            hasher.combine(httpError.statusCode)
        case .connection(let connectionError):
            switch connectionError.reason {
            case .notConnectedToInternet(let code):
                hasher.combine(code)
            case .cancelled:
                hasher.combine(-1)
            case .unexpected(let code):
                hasher.combine(code)
            }
        case .unexpected(let apiError):
            hasher.combine(apiError.debugDescription)
        }
    }

    public static func == (
        lhs: HIPNetworkError<APIErrorDetail>,
        rhs: HIPNetworkError<APIErrorDetail>
    ) -> Bool {
        switch (lhs, rhs) {
        case (.client(let lHttpError, _), .client(let rHttpError, _)),
             (.server(let lHttpError, _), .server(let rHttpError, _)):
            return lHttpError == rHttpError
        case (connection, .connection):
            return true
        case (.unexpected, .unexpected):
            return true
        default:
            return false
        }
    }
}

public enum HIPError<
    InAppError: Error & Hashable,
    APIErrorDetail: DebugPrintable
>: Error,
   Hashable,
   DebugPrintable {
    case inapp(InAppError)
    case network(HIPNetworkError<APIErrorDetail>)

    public init(inappError: InAppError) {
        self = .inapp(inappError)
    }

    public init(
        apiError: APIError,
        apiErrorDetail: APIErrorDetail? = nil
    ) {
        self = .network(
            HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
        )
    }
}

extension HIPError {
    public var debugDescription: String {
        switch self {
        case .inapp(let inappError):
            return """
            In-App
            \(inappError)
            """
        case .network(let networkError):
            return """
            Network
            \(networkError.debugDescription)
            """
        }
    }
}

extension HIPError {
    public func hash(
        into hasher: inout Hasher
    ) {
        switch self {
        case .inapp(let inappError):
            hasher.combine(inappError)
        case .network(let networkError):
            hasher.combine(networkError)
        }
    }
}
