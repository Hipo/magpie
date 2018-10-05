//
//  NetworkingError.swift
//  Pods
//
//  Created by Eray on 3.10.2018.
//

import UIKit

public enum NetworkingError<ObjectType: Decodable>: Error {
    case libraryError(_ error: LibraryError)
    case apiError(_ error: ApiError)
    case apiErrorWithObject(_ apiError: ApiError, _ object: ObjectType)
}

public enum LibraryError: Error {
    case unknown
    
    case invalidData(_ message: String?)
    case invalidUrl(_ message: String?)
    case jsonParsing(_ message: String?)
    case urlError(_ error: URLError)
}

public enum ApiError: Int, Error {
    case unknown                        = -1

    // 4xx Client Error
    case badRequest                     = 400
    case unauthorized                   = 401
    case paymentRequired                = 402
    case forbidden                      = 403
    case notFound                       = 404
    case methodNotAllowed               = 405
    case notAcceptable                  = 406
    case proxyAuthenticationRequired    = 407
    case timeout                        = 408
    case conflict                       = 409
    case gone                           = 410
    case lengthRequired                 = 411
    case preconditionFailed             = 412
    case largeRequest                   = 413
    case longURI                        = 414
    case unsupportedMediaType           = 415
    case unsatisfiableRange             = 416
    case expectationFailure             = 417
    case unprocessableEntity            = 422
    case locked                         = 423
    case failedDependency               = 424
    case upgradeRequired                = 426
    
    // 5xx Server Error
    case internalServerError            = 500
    case notImplemented                 = 501
    case badGateway                     = 502
    case serviceUnavailable             = 503
    case gatewayTimeout                 = 504
    case unsupportedHttpVersion         = 505
    case variantNegotiates              = 506
    case insufficientStorage            = 507
    case loopDetected                   = 508
    case notExtended                    = 510
    case networkAuthenticateionRequired = 511
}
