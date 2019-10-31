//
//  Error.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Foundation

public enum Error: FoundationError {
    public enum RequestEncoding: FoundationError {
        case emptyOrInvalidBaseURL(String?)
        case emptyOrInvalidURL(Request)
        case invalidURLQueryPair(RequestParameter, FoundationError)
        case failed(Request, FoundationError)
    }

    public enum ResponseSerialization: FoundationError {
        case emptyOrCorruptedData(Data?)
        case jsonSerializationFailed(Data?, FoundationError)
    }

    public enum NetworkMonitoring: FoundationError {
        case notStarted
    }

    case requestEncoding(RequestEncoding)
    case responseSerialization(ResponseSerialization)
    case redirection(HTTPError) /// 3xx
    case badRequest /// 400
    case unauthorized /// 401
    case forbidden /// 403
    case notFound /// 404
    case client(HTTPError) /// 4xx
    case notImplemented /// 501
    case serviceUnavailable /// 503
    case server(HTTPError) /// 5xx
    case networkUnavailable(URLError) /// URLError.Code.xxx related the network issues
    case cancelled /// URLError.Code.cancelled
    case unexpected(FoundationError?)
    case unknown(FoundationError?)
    case custom(Any?)
    case networkMonitoring(NetworkMonitoring)
}

extension Error {
    public var underlyingError: FoundationError? {
        switch self {
        case .requestEncoding(let err):
            return err
        case .responseSerialization(let err):
            return err
        case .redirection(let err),
             .client(let err),
             .server(let err):
            return err.underlyingError
        case .networkUnavailable(let err):
            return err
        case .unexpected(let err):
            return err
        case .unknown(let err):
            return err
        default:
            return nil
        }
    }

    public var localizedDescription: String {
        switch self {
        case .requestEncoding(let underlyingError):
            return underlyingError.localizedDescription
        case .responseSerialization(let underlyingError):
            return underlyingError.localizedDescription
        case .redirection(let httpError),
             .client(let httpError),
             .server(let httpError):
            return """
            Request failed.
            reason:
            \(httpError.statusCode) \(httpError.underlyingError.localizedDescription)
            """
        case .badRequest:
            return "400 Bad request"
        case .unauthorized:
            return "401 Unauthorized"
        case .forbidden:
            return "403 Forbidden"
        case .notFound:
            return "404 Not found"
        case .notImplemented:
            return "501 Not implemented"
        case .serviceUnavailable:
            return "503 Service unavailable"
        case .networkUnavailable(let underlyingError):
            return """
            Network is unavailable.
            reason:
            (\(underlyingError.code.rawValue))\(underlyingError.localizedDescription)
            """
        case .cancelled:
            return "Request is cancelled."
        case .unexpected(let underlyingError):
            return """
            There is something unexpected.
            reason:
            \(underlyingError?.localizedDescription ?? "<nil>")
            """
        case .unknown(let underlyingError):
            return """
            There is something unknown.
            reason:
            \(underlyingError?.localizedDescription ?? "<nil>")
            """
        case .custom(let underlyingError):
            return """
            It is an user-defined error.
            reason:
            \(underlyingError.map({ String(describing: $0)}) ?? "<nil>")
            """
        case .networkMonitoring(let underlyingError):
            return underlyingError.localizedDescription
        }
    }
}

extension Error {
    static func populate(from urlError: URLError) -> Error {
        switch urlError.code {
        case .timedOut,
             .cannotFindHost,
             .cannotConnectToHost,
             .networkConnectionLost,
             .dnsLookupFailed,
             .notConnectedToInternet,
             .internationalRoamingOff,
             .callIsActive,
             .dataNotAllowed:
            return .networkUnavailable(urlError)
        case .cancelled:
            return .cancelled
        default:
            return .unexpected(urlError)
        }
    }

    static func populate(from httpError: HTTPError) -> Error {
        switch httpError.statusCode {
        case 300..<400:
            return .redirection(httpError)
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 400..<500:
            return .client(httpError)
        case 501:
            return .notImplemented
        case 503:
            return .serviceUnavailable
        case 500..<600:
            return .server(httpError)
        default:
            return .unknown(httpError.underlyingError)
        }
    }
}

extension Error.RequestEncoding {
    public var localizedDescription: String {
        switch self {
        case .emptyOrInvalidBaseURL(let baseUrlString):
            guard let baseUrlString = baseUrlString else {
                return "Base URL is null."
            }
            return """
            Base url is invalid.
            data:
            \(baseUrlString)
            """
        case .emptyOrInvalidURL(let request):
            return """
            URL is invalid.
            request:
            \(request.description)
            """
        case .invalidURLQueryPair(let param, let underlyingError):
            return """
            URL query item is invalid.
            data:
            \(param.toString())
            reason:
            \(underlyingError.localizedDescription)
            """
        case .failed(let request, let underlyingError):
            return """
            Request encoding failed.
            request:
            \(request.description)
            reason:
            \(underlyingError.localizedDescription)
            """
        }
    }
}

extension Error.ResponseSerialization {
    public var localizedDescription: String {
        switch self {
        case .emptyOrCorruptedData(let responseData):
            guard let responseString = responseData?.toString() else {
                return "No response is received."
            }
            return """
            Response is corrupted.
            data:
            \(responseString)
            """
        case .jsonSerializationFailed(let responseData, let underlyingError):
            return """
            JSON serialization failed.
            data:
            \(responseData?.toString() ?? "<nil>")
            reason:
            \(underlyingError.localizedDescription)
            """
        }
    }
}

extension Error.NetworkMonitoring {
    public var localizedDescription: String {
        switch self {
        case .notStarted:
            return "The network monitoring couldn't be started for unknown reasons."
        }
    }
}

public struct HTTPError: FoundationError {
    let statusCode: Int
    let underlyingError: FoundationError
}
