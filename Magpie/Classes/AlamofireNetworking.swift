//
//  AlamofireNetworking.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation
import Alamofire

public final class AlamofireNetworking {
    public typealias TheRequest = DataRequest
    public typealias TheError = AlamofireNetworkingError
    
    private let shouldLogResponse = true

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
            request.responseClosure(
                Response.failed(AlamofireNetworkingError.invalidUrl)
            )
            
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
                
                self.performResponse(request, response, responseClosure, type: D.self)
        }
    }
    
    private func performResponse<D>(
        _ request: Request<AlamofireNetworking, D>,
        _ response: DataResponse<Any>,
        _ responseClosure: @escaping ResponseClosure,
        type: D.Type
        ) where D : Decodable {
        
        switch response.result {
        case .success:
            guard let data = response.data else {
                // TODO: Return relevant AlamofireNetworkingError
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
                responseClosure(Response.failed(AlamofireNetworkingError.jsonParsing))
            }
            
        case .failure(let error):
            // TODO: Convert errors into AlamofireNetworkingError cases
            responseClosure(Response.failed(error))
        }
    }
    
    public func cancelRequest<D: Decodable>(_ request: Request<AlamofireNetworking, D>) {
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
