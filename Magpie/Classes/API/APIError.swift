//
//  API.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Foundation

public protocol APIError: Error, Printable {
    var responseData: Data? { get }
}

extension APIError {
    public var responseData: Data? {
        return nil
    }
}

extension APIError {
    public var localizedDescription: String {
        return description
    }
}

public struct RequestEncodingError: APIError {
    public let reason: Reason

    public init(reason: Reason) {
        self.reason = reason
    }
}

extension RequestEncodingError {
    /// <mark> CustomStringConvertible
    public var description: String {
        switch reason {
        case .emptyOrInvalidURL:
            return "Invalid URL"
        case .invalidURLQueryEncoding(let key):
            return "Invalid query item for \(key)"
        case .invalidFormURLBodyEncoding(let key):
            return "Invalid form-url-encoded body param for \(key)"
        }
    }
}

extension RequestEncodingError {
    public enum Reason: Error {
        case emptyOrInvalidURL
        case invalidURLQueryEncoding(key: String)
        case invalidFormURLBodyEncoding(key: String)
    }
}

public struct EndpointOperationError: APIError {
    public let reason: Reason

    init(reason: Reason) {
        self.reason = reason
    }
}

extension EndpointOperationError {
    /// <mark> CustomStringConvertible
    public var description: String {
        switch reason {
        case .retryBeforeSent:
            return "'retry()' operation can be available after calling 'send()'"
        }
    }
}

extension EndpointOperationError {
    public enum Reason {
        case retryBeforeSent
    }
}

public struct ResponseSerializationError: APIError {
    public let responseData: Data?
    public let reason: Reason

    public init(
        responseData: Data?,
        reason: Reason
    ) {
        self.responseData = responseData
        self.reason = reason
    }
}

extension ResponseSerializationError {
    /// <mark> CustomStringConvertible
    public var description: String {
        switch reason {
        case .corruptedData:
            return "Corrupted data"
        case .jsonSerializationFailed:
            return "JSON serialization failed"
        }
    }
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "\(description)\n\(responseData.absoluteUtf8Description)"
    }
}

extension ResponseSerializationError {
    public enum Reason {
        case corruptedData
        case jsonSerializationFailed(underlyingError: Error)
    }
}

public struct HTTPError: APIError {
    public let statusCode: Int
    public let responseData: Data?
    public let reason: Reason

    public init(
        statusCode: Int,
        responseData: Data?,
        underlyingError: Error? = nil
    ) {
        self.statusCode = statusCode
        self.responseData = responseData

        switch statusCode {
        case 300..<400:
            reason = .redirection(underlyingError: underlyingError)
        case 400:
            reason = .badRequest
        case 401:
            reason = .unauthorized
        case 403:
            reason = .forbidden
        case 404:
            reason = .notFound
        case 400..<500:
            reason = .client(underlyingError: underlyingError)
        case 501:
            reason = .notImplemented
        case 503:
            reason = .serviceUnavailable
        case 500..<600:
            reason = .server(underlyingError: underlyingError)
        default:
            reason = .unknown(underlyingError: underlyingError)
        }
    }
}

extension HTTPError {
    /// <mark> CustomStringConvertible
    public var description: String {
        switch reason {
        case .badRequest:
            return "Bad Request"
        case .unauthorized:
            return "Unauthorized"
        case .forbidden:
            return "Forbidden"
        case .notFound:
            return "Not found"
        case .notImplemented:
            return "Not implemented"
        case .serviceUnavailable:
            return "Service unavailable"
        default:
            return "Status \(statusCode)"
        }
    }
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        switch reason {
        case .redirection(let underlyingError),
             .client(let underlyingError),
             .server(let underlyingError),
             .unknown(let underlyingError):
            return """
            \(description)
            \(underlyingError?.localizedDescription ?? "nil")
            \(responseData.absoluteUtf8Description)
            """
        default:
            return "\(description)\n\(responseData.absoluteUtf8Description)"
        }
    }
}

extension HTTPError {
    public enum Reason {
        case redirection(underlyingError: Error?) /// <note> 3xx
        case badRequest /// <note> 400
        case unauthorized /// <note> 401
        case forbidden /// <note> 403
        case notFound /// <note> 404
        case client(underlyingError: Error?) /// <note> 4xx
        case notImplemented /// <note> 501
        case serviceUnavailable /// <note> 503
        case server(underlyingError: Error?) /// <note> 5xx
        case unknown(underlyingError: Error?)
    }
}

public struct NetworkError: APIError {
    public let reason: Reason
    public let underlyingError: URLError?

    public init(reason: Reason) {
        self.reason = reason
        self.underlyingError = nil
    }

    public init(urlError: URLError) {
        underlyingError = urlError

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
            reason = .notConnectedToInternet(urlError.code)
        case .cancelled:
            reason = .cancelled
        default:
            reason = .unexpected(urlError.code)
        }
    }
}

extension NetworkError {
    /// <mark> CustomStringConvertible
    public var description: String {
        switch reason {
        case .notConnectedToInternet:
            return "Not connected to internet"
        case .cancelled:
            return "Cancelled"
        case .unexpected(let code):
            return "Unexpected \(code)"
        }
    }
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        if let underlyingError = underlyingError {
            return "\(description)\n\(underlyingError.localizedDescription)"
        }
        return description
    }
}

extension NetworkError {
    public enum Reason {
        case notConnectedToInternet(URLError.Code)
        case cancelled
        case unexpected(URLError.Code)
    }
}

public struct UnexpectedError: APIError {
    public let responseData: Data?
    public let underlyingError: Error?

    public init(
        responseData: Data?,
        underlyingError: Error?
    ) {
        self.responseData = responseData
        self.underlyingError = underlyingError
    }
}

extension UnexpectedError {
    /// <mark> CustomStringConvertible
    public var description: String {
        return "Unexpected"
    }

    public var debugDescription: String {
        return "\(description)\n\(underlyingError?.localizedDescription ?? "<nil>")"
    }
}