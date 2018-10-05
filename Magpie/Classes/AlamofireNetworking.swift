//
//  AlamofireNetworking.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation
import Alamofire

public final class AlamofireNetworking<ErrorObject: Decodable> {
    public typealias TheRequest = DataRequest
    public typealias TheError = NetworkingError<ErrorObject>
    public typealias TheErrorObject = ErrorObject
    
    private let shouldLogResponse = false

    /// MARK: Initialization
    
    public init() {
        
    }
    
    // MARK: Helpers
    
    fileprivate func logResponseIfNeeded(_ response: DataResponse<Any>) {
        if !shouldLogResponse {
            return
        }
        
        log(request: response.request,
            response: response.response,
            data: response.data,
            value: response.value,
            result: response.result
        )
    }
}

extension AlamofireNetworking: Networking {
    public func sendRequest<D: Decodable>(
        _ request: Request<AlamofireNetworking, D>
        ) -> TheRequest? {
        guard let url = URL(string: request.base + request.path) else {
            let message = ""
            request.responseClosure(Response.failed(LibraryError.invalidUrl(message)))
            
            return nil
        }
        
        let dataRequest = alamofireRequest(
            url,
            request,
            request.responseClosure,
            type: D.self
        )
        
        return dataRequest
    }
    
    private func alamofireRequest<D>(
        _ url: URL,
        _ request: Request<AlamofireNetworking, D>,
        _ responseClosure: @escaping ResponseClosure,
        type: D.Type
        ) -> DataRequest where D: Decodable {
        return Alamofire.request(
            url,
            method: request.method,
            parameters: request.parameters,
            encoding: request.encoding,
            headers: request.headers
            )
            .validate()
            .responseJSON { (response) in
                self.logResponseIfNeeded(response)
                
                self.perform(request, response, responseClosure, type: D.self)
        }
    }
    
    private func perform<D>(
        _ request: Request<AlamofireNetworking, D>,
        _ response: DataResponse<Any>,
        _ responseClosure: @escaping ResponseClosure,
        type: D.Type
        ) where D: Decodable {
        
        switch response.result {
        case .success:
            guard let data = response.data else {
                let message = ""
                responseClosure(Response.failed(LibraryError.invalidData(message)))
                
                return
            }
            
            do {
                switch response.type {
                case .unknown,
                     .dictionary:
                    let parsedObject = try JSONDecoder().decode(D.self, from: data)
                    
                    responseClosure(Response.success(parsedObject))
                case .array:
                    let parsedObject = try JSONDecoder().decode([D].self, from: data)

                    responseClosure(Response.success(parsedObject))
                }
            } catch {
                let message = ""
                responseClosure(Response.failed(LibraryError.jsonParsing(message)))
            }
            
        case .failure(let error):
            guard let data = response.data else {
                let message = ""
                responseClosure(Response.failed(LibraryError.invalidData(message)))
                
                return
            }

            let handledError = handleError(error, with: data)
            
            responseClosure(Response.failed(handledError))
        }
    }
    
    public func cancelRequest(_ request: RequestProtocol) {
        /// (request.original as? DataRequest)?.cancel()
        /// If it is ok using the code above, we can remove the generic dependency throughout the code.
        request.original?.cancel()
    }
    
    public func cancelOngoingRequests() {
        Alamofire
            .SessionManager
            .default
            .session
            .getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
                dataTasks.forEach { $0.cancel() }
                uploadTasks.forEach { $0.cancel() }
                downloadTasks.forEach { $0.cancel() }
        }
    }
}

extension AlamofireNetworking {
    internal func handleError(_ error: Error, with data: Data) -> NetworkingError<ErrorObject> {
        if let error = error as? AFError {
            return handleAFError(error, with: data)
        } else if let error = error as? URLError {
            return handleURLError(error)
        } else {
            return .libraryError(.unknown)
        }
    }
    
    internal func handleAFError(_ error: AFError, with data: Data) -> NetworkingError<ErrorObject> {
        print(">>> AFError \(error)")
        
        guard let responseCode = error.responseCode else {
            return .libraryError(.unknown)
        }
        
        guard let apiError = ApiError(rawValue: responseCode) else {
            return .apiError(.unknown)
        }
        
        do {
            let errorObject = try JSONDecoder().decode(ErrorObject.self, from: data)
            
            return .apiErrorWithObject(apiError, errorObject)
        } catch {
            return .libraryError(.jsonParsing("Error while decoding error object"))
        }
    }
    
    internal func handleURLError(_ error: URLError) -> NetworkingError<ErrorObject> {
        print(">>> URL Error Code: \(error.code)")
        
        return .libraryError(.urlError(error))
    }
}
