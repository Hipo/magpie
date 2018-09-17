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
            print(">>> JSON: \(json)")
        }
        
        print(">>> RESULT: \(response.result)")
    }
}

extension AlamofireNetworking: Networking {
    public func sendRequest(_ request: Request<AlamofireNetworking>) -> TheRequest {
        // TODO: Throw invalid url error here
        let url = URL(string: request.base + request.path)!
        
        let dataRequest = Alamofire
            .request(url)
            .validate()
            .responseJSON { (response) in
                
                self.logResponseIfNeeded(response)
        }
        
        return dataRequest
    }
    
    public func cancelRequest(_ request: Request<AlamofireNetworking>) {
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
