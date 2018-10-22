//
//  AlamofireNetworking.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Alamofire
import Foundation

public class AlamofireNetworking {
    required public init() {
    }
}

extension AlamofireNetworking: Networking {
    public func send<ObjectType>(
        _ request: Request<ObjectType>,
        handler: DataResponseHandler?)
        -> TaskCancellable?
    where ObjectType : Mappable {
        do {
            let urlRequest = try request.asURLRequest()
            return Alamofire.request(urlRequest)
                .validate()
                .responseData(completionHandler: { (response) in
                    switch response.result {
                    case .success:
                        handler?(.success(response.data))
                    case .failure(let error):
                        if let afError = error as? AFError {
                            handler?(.failure(
                                Error(afError: afError, responseData: response.data))
                            )
                            return
                        }
                        handler?(.failure(
                            Error(error: error as NSError, responseData: response.data))
                        )
                    }
            })
        } catch let error as Error {
            handler?(.failure(error))
        } catch let err {
            handler?(.failure(.unknown(err)))
        }
        return nil
    }
    
    public func cancel<ObjectType>(_ request: Request<ObjectType>) where ObjectType: Mappable {
        request.task?.cancel()
    }
    
    public func cancelAll() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler {
            (dataTasks, _, _) in
            dataTasks.forEach { $0.cancel() }
        }
    }
}
