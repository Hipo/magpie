//
//  HipNetworkClient.swift
//  Magpie
//
//  Created by Eray on 12.09.2018.
//

import Foundation
import Alamofire

public class Magpie: NetworkService {
    public typealias RequestObject = Request
    public typealias SuccessHandler = (Any) -> Void
    public typealias FailHandler = (MagpieError) -> Void
    
    private let shouldLogResponse = false
    
    public init() { }
    
    public func send(
        _ request: Request,
        onSuccess successClosure: @escaping SuccessHandler,
        onFail failClosure: @escaping FailHandler) {
        
        Alamofire.request(request.url).validate().responseJSON { (response) in
            self.logResponseIfNeeded(response)
            
            if let JSON = response.result.value {
                successClosure(JSON)
            } else {
                failClosure(MagpieError.jsonParsing)
            }
        }
    }
    
    public func cancelAllRequests() {
        Alamofire.SessionManager.default
            .session
            .getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
                
                dataTasks.forEach { $0.cancel() }
                uploadTasks.forEach { $0.cancel() }
                downloadTasks.forEach { $0.cancel() }
        }
    }
    
    // MARK: Helpers
    
    private func logResponseIfNeeded(_ response: DataResponse<Any>) {
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
        
        print(">>> RESULT: \(response.result)")
    }
}

extension Magpie {
    public enum MagpieError: Error {
        case jsonParsing
    }
}
