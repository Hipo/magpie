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
            let dataRequest = Alamofire.request(urlRequest)

            if validateFirst {
                dataRequest.validate()
            }
            return dataRequest.responseData() { [weak self] dataResponse in
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
                uploadRequest = Alamofire.upload(data, with: urlRequest)
            case .file(let url):
                uploadRequest = Alamofire.upload(url, with: urlRequest)
            }

            if validateFirst {
                uploadRequest.validate()
            }
            return uploadRequest.responseData() { [weak self] dataResponse in
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

    private func populateResponse(from dataResponse: DataResponse<Data>, for request: Request) -> Response {
        switch dataResponse.result {
        case .success:
            return Response(request: request, data: dataResponse.data)
        case .failure(let error):
            let response = Response(request: request, data: dataResponse.data)

            if let afError = error as? AFError {
                if let code = afError.responseCode {
                    let httpError = HTTPError(statusCode: code, underlyingError: afError)
                    let error = Error.populate(from: httpError)

                    response.errorContainer = ErrorContainer(origin: .magpie(error))
                    return response
                }
                response.errorContainer = ErrorContainer(origin: .unknown(afError))
                return response
            }
            let err = Error.populate(from: error as NSError)
            response.errorContainer = ErrorContainer(origin: .magpie(err))
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
