//
//  AlamofireNeetworking.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation
import Alamofire

public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias HTTPHeaders = [String: String]
public typealias Parameters = [String: String]

public typealias ParameterEncoding = Alamofire.ParameterEncoding
public typealias JSONEncoding = Alamofire.JSONEncoding
public typealias URLEncoding = Alamofire.URLEncoding

extension DataRequest: RequestConvertable {
}

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
        
        if let request = response.request {
            print(">>> REQUEST: \(request)")
        }
        
        if let response = response.response {
            print(">>> RESPONSE: \(response)")
        }
        
        if let data = response.data {
            print(">>> DATA: \(data)")
        }
        
        if let json = response.result.value {
            prettyPrint(json: json)
        }
        
        print(">>> RESULT: \(response.result)")
    }
    
    fileprivate func prettyPrint(json: Any) {
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
            return
        }
        
        guard let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
            return
        }
        
        print(">>> JSON: \(string)")
    }
}

extension AlamofireNetworking: Networking {
    public func sendRequest<C: Decodable>(
        _ request: Request<AlamofireNetworking, C>
        ) -> TheRequest? {
        guard let url = URL(string: request.base + request.path) else {
            request.responseClosure(Response.failed(AlamofireNetworkingError.invalidUrl))
            return nil
        }
        
        let dataRequest = Alamofire
            .request(
                url,
                method: request.method,
                parameters: request.parameters,
                encoding: request.encoding,
                headers: request.headers
            )
            .validate()
            .responseJSON { (response) in
                self.logResponseIfNeeded(response)
                                
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
                            let parsedObject = try JSONDecoder().decode(C.self, from: data)
                            
                            request.responseClosure(Response.success(parsedObject))
                        case .array:
                            let parsedObject = try JSONDecoder().decode([C].self, from: data)
                            
                            request.responseClosure(Response.success(parsedObject))
                        }
                    } catch {
                        request.responseClosure(
                            Response.failed(AlamofireNetworkingError.jsonParsing)
                        )
                    }
                    
                case .failure(let error):
                    // TODO: Convert errors into AlamofireNetworkingError cases
                    request.responseClosure(Response.failed(error))
                }
        }
        
        return dataRequest
    }
        
    public func cancelRequest<C: Decodable>(_ request: Request<AlamofireNetworking, C>) {
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
