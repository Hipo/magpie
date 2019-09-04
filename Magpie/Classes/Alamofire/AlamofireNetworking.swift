//
//  AlamofireNetworking.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Alamofire
import Foundation

public class AlamofireNetworking: Networking {
    public init() { }

    public func send(_ request: Request, validateFirst: Bool, then handler: @escaping ResponseHandler) -> TaskConvertible? {
        do {
            let urlRequest = try request.asUrlRequest()
            let dataRequest = AF.request(urlRequest)

            if validateFirst {
                dataRequest.validate()
            }
            return dataRequest.magpie_responseData { [weak self] dataResponse in
                guard let self = self else {
                    return
                }
                let response = self.populateResponse(from: dataResponse, for: request)
                handler(response)
            }
        } catch let error {
            let response = populateResponse(from: error, for: request)
            handler(response)
        }
        return nil
    }

    public func upload(
        _ source: EndpointContext.Source,
        with request: Request,
        validateFirst: Bool,
        then handler: @escaping ResponseHandler
    ) -> TaskConvertible? {
        do {
            let urlRequest = try request.asUrlRequest()
            let uploadRequest: UploadRequest

            switch source {
            case .data(let data):
                uploadRequest = AF.upload(data, with: urlRequest)
            case .file(let url):
                uploadRequest = AF.upload(url, with: urlRequest)
            }

            if validateFirst {
                uploadRequest.validate()
            }
            return uploadRequest.magpie_responseData { [weak self] dataResponse in
                guard let self = self else {
                    return
                }
                let response = self.populateResponse(from: dataResponse, for: request)
                handler(response)
            }
        } catch let error {
            let response = populateResponse(from: error, for: request)
            handler(response)
        }
        return nil
    }

    private func populateResponse(from dataResponse: AFDataResponse<Data>, for request: Request) -> Response {
        switch dataResponse.result {
        case .success:
            return Response(request: request, fields: dataResponse.response?.allHeaderFields, data: dataResponse.data)
        case .failure(let error):
            let response = Response(request: request, fields: dataResponse.response?.allHeaderFields, data: dataResponse.data)

            if let code = error.responseCode {
                let httpError = HTTPError(statusCode: code, underlyingError: error)
                let error = Error.populate(from: httpError)

                response.errorContainer = ErrorContainer(origin: .magpie(error))
                return response
            }
            response.errorContainer = ErrorContainer(origin: .unknown(error))
            return response
        }
    }

    private func populateResponse(from error: FoundationError, for request: Request) -> Response {
        guard let magError = error as? Error else {
            let errorContainer = ErrorContainer(origin: .foundation(error))
            return Response(request: request, errorContainer: errorContainer)
        }
        let errorContainer = ErrorContainer(origin: .magpie(magError))
        return Response(request: request, errorContainer: errorContainer)
    }
}
