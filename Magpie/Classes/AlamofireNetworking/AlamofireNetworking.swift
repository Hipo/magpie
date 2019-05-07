//
//  AlamofireNetworking.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Alamofire
import Foundation

open class AlamofireNetworking {
    required public init() {
    }
}

extension AlamofireNetworking: NetworkingProtocol {
    public func send<ObjectType>(
        _ request: Request<ObjectType>,
        handler: DataResponseHandler?
    ) -> TaskCancellable? where ObjectType : Mappable {
        do {
            let urlRequest = try request.asUrlRequest()
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
    
    public func sendInvalidated<ObjectType>(
        _ request: Request<ObjectType>,
        handler: DataResponseHandler?
    ) -> TaskCancellable? where ObjectType : Mappable {
        do {
            let urlRequest = try request.asUrlRequest()
            return Alamofire.request(urlRequest)
                .responseData(completionHandler: { (response) in
                    let statusCode = response.response?.statusCode ?? 500
                    
                    guard statusCode >= 200 && statusCode < 300 else {
                        handler?(.failure(.unknown(response.error)))
                        return
                    }
                    
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
    
    public func upload<ObjectType>(
        _ request: Request<ObjectType>,
        withData data: Data,
        handler: DataResponseHandler?
        ) -> TaskCancellable? where ObjectType : Mappable {
        do {
            let urlRequest = try request.asUrlRequest()
            
            return Alamofire.upload(data, with: urlRequest)
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
}
