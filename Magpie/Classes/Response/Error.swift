//
//  Error.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Foundation

public typealias SystemError = Swift.Error
public typealias SystemURLError = URLError
public typealias HTTPError = (statusCode: Int, underlyingError: SystemError?, responseData: Data?)

public enum Error {
    public enum RequestEncoding {
        case emptyOrInvalidBaseURL(String?)
        case emptyOrInvalidURL(String?)
        case invalidURLQuery(Params)
        case invalidHTTPBody(Params, SystemError?)
    }

    public enum ResponseSerialization {
        case emptyOrCorruptedData(Data?)
        case jsonSerializationFailed(Data?, SystemError?)
    }

    case requestEncoding(RequestEncoding)
    case responseSerialization(ResponseSerialization)
    case redirection(HTTPError) /// 3xx
    case badRequest(Data?) /// 400
    case unauthorized(Data?) /// 401
    case forbidden(Data?) /// 403
    case notFound(Data?) /// 404
    case client(HTTPError) /// 4xx
    case notImplemented(Data?) /// 501
    case serviceUnavailable(Data?) /// 503
    case server(HTTPError) /// 5xx
    case networkUnavailable(SystemURLError?) /// URLError.Code.xxx related the network issues
    case cancelled /// URLError.Code.cancelled
    case unexpected(SystemURLError?)
    case unknown(SystemError?)
}

extension Error: SystemError {
    public var localizedDescription: String {
        switch self {
        case .requestEncoding(let err):
            return err.localizedDescription
        case .responseSerialization(let err):
            return err.localizedDescription
        case .redirection(let err),
             .client(let err),
             .server(let err):
            let responseJSON = err.responseData.map { try? $0.toJSON() } ?? nil
            return """
            Request failed: \(err.statusCode)
            Reason: \(err.underlyingError?.localizedDescription ?? "null")
            Response Data: \(responseJSON ?? "null")
            """
        case .badRequest:
            return "Bad request"
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
        case .networkUnavailable(let err):
            return "Network Unavailable. Reason: \(err?.localizedDescription ?? "null")"
        case .cancelled:
            return "Cancelled"
        case .unexpected(let err):
            return "Unexpected URL error. Reason: \(err?.localizedDescription ?? "null")"
        case .unknown(let err):
            return "Unknown error. Reason: \(err?.localizedDescription ?? "null")"
        }
    }
}

extension Error.RequestEncoding: SystemError {
    public var localizedDescription: String {
        switch self {
        case .emptyOrInvalidBaseURL(let urlString):
            return "Invalid base url: \(urlString ?? "null")"
        case .emptyOrInvalidURL(let urlString):
            return "Invalid url: \(urlString ?? "null")"
        case .invalidURLQuery(let params):
            return "Invalid url query: \(params.description)"
        case .invalidHTTPBody(let params, let err):
            return """
            Invalid http body: \(params.description)
            Reason: \(err?.localizedDescription ?? "null")
            """
        }
    }
}

extension Error.ResponseSerialization: SystemError {
    public var localizedDescription: String {
        switch self {
        case .emptyOrCorruptedData(let responseData):
            let responseJSON = responseData.map { try? $0.toJSON() } ?? nil
            return "Corrupted data: \(responseJSON ?? "null")"
        case .jsonSerializationFailed(let responseData, let err):
            let responseJSON = responseData.map { try? $0.toJSON() } ?? nil
            return """
            JSON serialization failed. Data: \(responseJSON ?? "null")
            Reason: \(err?.localizedDescription ?? "null")
            """
        }
    }
}

extension Error {
    public var underlyingError: SystemError? {
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
}

extension Error {
    init(error: NSError, responseData: Data? = nil) {
        if error.domain == NSURLErrorDomain, let urlError = error as? URLError {
            self = Error.error(from: urlError)
            return
        }
        self = Error.error(from: (
            statusCode: error.code,
            underlyingError: error,
            responseData: responseData
            )
        )
    }
}

extension Error {
    public func decodedError<T>() -> T? where T: Mappable {
        switch self {
        case .redirection(let err),
             .client(let err),
             .server(let err):
            return err.responseData.map { try? T.decoded(from: $0) } ?? nil
        case .badRequest(let responseData),
             .unauthorized(let responseData),
             .forbidden(let responseData),
             .notFound(let responseData),
             .notImplemented(let responseData),
             .serviceUnavailable(let responseData):
            return responseData.map { try? T.decoded(from: $0) } ?? nil
        default:
            return nil
        }
    }
}

extension Error {
    static func error(from urlError: URLError) -> Error {
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
    
    static func error(from httpError: HTTPError) -> Error {
        switch httpError.statusCode {
        case 300..<400:
            return .redirection(httpError)
        case 400:
            return .badRequest(httpError.responseData)
        case 401:
            return .unauthorized(httpError.responseData)
        case 403:
            return .forbidden(httpError.responseData)
        case 404:
            return .notFound(httpError.responseData)
        case 400..<500:
            return .client(httpError)
        case 501:
            return .notImplemented(httpError.responseData)
        case 503:
            return .serviceUnavailable(httpError.responseData)
        case 500..<600:
            return .server(httpError)
        default:
            return .unknown(httpError.underlyingError)
        }
    }
}
