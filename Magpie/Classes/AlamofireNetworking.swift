//
//  AlamofireNeetworking.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation
import Alamofire

extension DataRequest: RequestConvertable {
}

public final class AlamofireNetworking {
    public typealias TheRequest = DataRequest
    
    /// MARK: Initialization
    public init() {
    }
}

extension AlamofireNetworking: Networking {
    public func sendRequest(_ request: Request<AlamofireNetworking>) -> TheRequest {
        fatalError("Return Alamofire dataRequest here.")
    }
    
    public func cancelRequest(_ request: Request<AlamofireNetworking>) {
        /// (request.original as? DataRequest)?.cancel()
        /// If it is ok using the code above, we can remove the generic dependency throughout the code.
        request.original?.cancel()
    }
    
    public func cancelOngoingRequests() {
    }
}
