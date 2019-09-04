//
//  Alamofire+TaskConvertible.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Alamofire
import Foundation

extension Alamofire.DataRequest: TaskConvertible {
    public var underlyingTask: URLSessionTask? {
        return task
    }

    public func cancelImmediately() {
        cancel()
    }
}

extension Alamofire.DataRequest {
    public func magpie_responseData(completionHandler: @escaping (AFDataResponse<Data>) -> Void) -> Self {
        return response(responseSerializer: DataResponseSerializer(emptyResponseCodes: Set(200..<300)), completionHandler: completionHandler)
    }
}
