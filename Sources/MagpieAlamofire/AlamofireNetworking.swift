// Copyright © 2020 hipolabs. All rights reserved.

import Alamofire
import Foundation
import MagpieCore

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
    private(set) lazy var afSession = Alamofire.Session.default

    private let acceptableStatusCodes = 200..<300

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
    open func send(_ request: MagpieCore.Request, validateResponse: Bool, queue: DispatchQueue, using handler: @escaping ResponseHandler) -> TaskConvertible? {
        do {
            let urlRequest = try request.asUrlRequest()
            let dataRequest = afSession.request(urlRequest)

            if validateResponse {
                dataRequest.validate()
            }
            return dataRequest.magpie_responseData(in: queue) { [weak self] dataResponse in
                if let self = self {
                    handler(self.convert(dataResponse, for: request))
                }
            }
        } catch let error {
            handler(convert(error, for: request))
            return nil
        }
    }

    open func download(_ request: MagpieCore.Request, to destination: EndpointType.DownloadDestination, validateResponse: Bool, queue: DispatchQueue, using handler: @escaping ResponseHandler) -> TaskConvertible? {
        do {
            let urlRequest = try request.asUrlRequest()
            let downloadRequest = createDownloadRequest(urlRequest: urlRequest, to: destination)

            if validateResponse {
                downloadRequest.validate(statusCode: acceptableStatusCodes)
            }

            return downloadRequest.magpie_responseURL(in: queue) { [weak self] downloadResponse in
                if let self = self {
                    handler(self.convert(downloadResponse, for: request))
                }
            }
        } catch {
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
    open func upload(_ request: MagpieCore.Request, from source: EndpointType.UploadSource, validateResponse: Bool, queue: DispatchQueue, using handler: @escaping ResponseHandler) -> TaskConvertible? {
        do {
            let urlRequest = try request.asUrlRequest()
            let uploadRequest = createUploadRequest(urlRequest: urlRequest, from: source)

            if validateResponse {
                uploadRequest.validate()
            }
            return uploadRequest.magpie_responseData(in: queue) { [weak self] dataResponse in
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
    open func upload(_ request: MagpieCore.Request, from form: MultipartForm, validateResponse: Bool, queue: DispatchQueue, using handler: @escaping ResponseHandler) -> TaskConvertible? {
        do {
            let urlRequest = try request.asUrlRequest()
            let uploadRequest = afSession.upload(multipartFormData: { form.append(into: $0) }, with: urlRequest)

            if validateResponse {
                uploadRequest.validate()
            }
            return uploadRequest.magpie_responseData(in: queue) { [weak self] dataResponse in
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
    private func convert(_ dataResponse: AFDataResponse<Data>, for request: MagpieCore.Request) -> Response {
        switch dataResponse.result {
        case .success:
            return Response(request: request, rawHeaders: dataResponse.response?.allHeaderFields, rawData: dataResponse.data)
        case .failure(let afError):
            let error = convert(afError, with: dataResponse.data)
            return Response(request: request, rawHeaders: dataResponse.response?.allHeaderFields, rawData: dataResponse.data, error: error)
        }
    }

    private func convert(_ dataResponse: AFDownloadResponse<URL>, for request: MagpieCore.Request) -> Response {
        switch dataResponse.result {
        case .success(let fileURL):
            let download = [
                "url": fileURL
            ]
            let downloadData = try? download.encoded()
            return Response(request: request, rawHeaders: dataResponse.response?.allHeaderFields, rawData: downloadData)
        case .failure(let afError):
            let errorData = dataResponse.fileURL.unwrap { try? Data(contentsOf: $0) }
            let error = convert(afError, with: errorData)
            return Response(request: request, rawHeaders: dataResponse.response?.allHeaderFields, rawData: errorData, error: error)
        }
    }

    private func convert(_ error: Error, for request: MagpieCore.Request) -> Response {
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

extension AlamofireNetworking {
    private func createDownloadRequest(urlRequest: URLRequest, to destination: EndpointType.DownloadDestination) -> DownloadRequest {
        switch destination {
        case .file(let url):
            return createDownloadRequest(urlRequest: urlRequest, to: url)
        }
    }

    private func createDownloadRequest(urlRequest: URLRequest, to fileURL: URL) -> DownloadRequest {
        return afSession.download(urlRequest) {
            [weak self] temporaryURL, response in
            guard let self = self else {
                return (temporaryURL, [])
            }

            if self.acceptableStatusCodes.contains(response.statusCode) {
                return (fileURL, [.removePreviousFile])
            } else {
                let failedFileURL = self.createFileURLForFailedDownload(temporary: temporaryURL)
                return (failedFileURL, [])
            }
        }
    }

    private func createFileURLForFailedDownload(temporary temporaryURL: URL) -> URL {
        let filename = "Alamofire_\(temporaryURL.lastPathComponent)"
        return temporaryURL.deletingLastPathComponent().appendingPathComponent(filename)
    }
}

extension AlamofireNetworking {
    private func createUploadRequest(urlRequest: URLRequest, from source: EndpointType.UploadSource) -> UploadRequest {
        switch source {
        case .data(let data):
            return createUploadRequest(urlRequest: urlRequest, from: data)
        case .file(let url):
            return createUploadRequest(urlRequest: urlRequest, from: url)
        }
    }

    private func createUploadRequest(urlRequest: URLRequest, from data: Data) -> UploadRequest {
        return afSession.upload(data, with: urlRequest)
    }

    private func createUploadRequest(urlRequest: URLRequest, from fileURL: URL) -> UploadRequest {
        return afSession.upload(fileURL, with: urlRequest)
    }
}
