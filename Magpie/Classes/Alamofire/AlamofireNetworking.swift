// Copyright © 2020 hipolabs. All rights reserved.

import Alamofire
import Foundation

/**
 The `Alamofire`-based implementation of `Networking` protocol.
 The library is implemented as a stand-alone solution free of how the network layer manages the
 connections. It just requires the passing instance to have a certain interface.
 On the other hand, `Alamofire` is one of the most-used networking libraries in the open-source
 community, so `AlamofireNetworking` is provided as a seperate module for those who like to use.
 */

/// <mark>
/// **Networking**
open class AlamofireNetworking: Networking {
    /// Initializes a new object.
    public init() { }

    /**
     Sends a request and calls the handler when the server returns a success or failure response.

     - Parameters:
        - request: The request object to be sent.
        - validateResponse: The flag to check the response if the status code is acceptable.
        - handler: The handler to be called with the built-in response object.

     - Returns: An instance of `TaskConvertible` to identify and manage the data request to be sent.
     */
    open func send(_ request: Request, validateResponse: Bool, onReceived handler: @escaping ResponseHandler) -> TaskConvertible? {
        do {
            let urlRequest = try request.asUrlRequest()
            let dataRequest = AF.request(urlRequest)

            if validateResponse {
                dataRequest.validate()
            }
            return dataRequest.magpie_responseData { [weak self] dataResponse in
                if let self = self {
                    handler(self.convert(dataResponse, for: request))
                }
            }
        } catch let error {
            handler(convert(error, for: request))
            return nil
        }
    }

    /**
     Uploads a data source with a request and calls the handler when the server returns a success
     or a failure response.

     - Parameters:
        - source: The data source to be uploaded.
        - request: The request object to be sent.
        - validateResponse:The flag to check the response if the status code is acceptable.
        - handler: The handler to be called with the built-in response object.

     - Returns: An instance of `TaskConvertible` to identify and manage the request to be sent with
     an uploadable source.
     */
    open func upload(_ source: EndpointType.Source, with request: Request, validateResponse: Bool, onCompleted handler: @escaping ResponseHandler) -> TaskConvertible? {
        do {
            let urlRequest = try request.asUrlRequest()

            let uploadRequest: UploadRequest

            switch source {
            case .data(let data):
                uploadRequest = AF.upload(data, with: urlRequest)
            case .file(let url):
                uploadRequest = AF.upload(url, with: urlRequest)
            }

            if validateResponse {
                uploadRequest.validate()
            }
            return uploadRequest.magpie_responseData { [weak self] dataResponse in
                if let self = self {
                    handler(self.convert(dataResponse, for: request))
                }
            }
        } catch let error {
            handler(convert(error, for: request))
            return nil
        }
    }

    /**
     Uploads a data source with a multipart request and calls the handler when the server returns
     a success or a failure response.

     - Parameters:
        - form: The form with the encoded data to be uploaded.
        - request: The request object to be sent.
        - validateResponse:The flag to check the response if the status code is acceptable.
        - handler: The handler to be called with the built-in response object.

     - Returns: An instance of `TaskConvertible` to identify and manage the request to be sent with
     an uploadable source.
     */
    open func upload(_ form: MultipartForm, with request: Request, validateResponse: Bool, onCompleted handler: @escaping ResponseHandler) -> TaskConvertible? {
        do {
            let urlRequest = try request.asUrlRequest()
            let uploadRequest = AF.upload(multipartFormData: { form.append(into: $0) }, with: urlRequest)

            if validateResponse {
                uploadRequest.validate()
            }
            return uploadRequest.magpie_responseData { [weak self] dataResponse in
                if let self = self {
                    handler(self.convert(dataResponse, for: request))
                }
            }
        } catch let error {
            handler(convert(error, for: request))
            return nil
        }
    }
}

extension AlamofireNetworking {
    private func convert(_ dataResponse: AFDataResponse<Data>, for request: Request) -> Response {
        switch dataResponse.result {
        case .success:
            return Response(request: request, rawHeaders: dataResponse.response?.allHeaderFields, rawData: dataResponse.data)
        case .failure(let afError):
            let error = convert(afError, with: dataResponse.data)
            return Response(request: request, rawHeaders: dataResponse.response?.allHeaderFields, rawData: dataResponse.data, error: error)
        }
    }

    private func convert(_ error: Error, for request: Request) -> Response {
        if let apiError = error as? APIError {
            return Response(request: request, error: apiError)
        }
        let unexpectedError = UnexpectedError(responseData: nil, underlyingError: error)
        return Response(request: request, error: unexpectedError)
    }

    private func convert(_ afError: AFError, with data: Data?) -> APIError {
        switch afError {
        case .explicitlyCancelled:
            return ConnectionError(reason: .cancelled)
        case .responseValidationFailed(let reason):
            if case .unacceptableStatusCode(let code) = reason {
                return HTTPError(statusCode: code, responseData: data, underlyingError: afError)
            } else {
                return UnexpectedError(responseData: data, underlyingError: afError)
            }
        case .sessionTaskFailed(let error):
            if let urlError = error as? URLError {
                return ConnectionError(urlError: urlError)
            } else {
                return UnexpectedError(responseData: data, underlyingError: error)
            }
        default:
            return UnexpectedError(responseData: data, underlyingError: afError)
        }
    }
}
