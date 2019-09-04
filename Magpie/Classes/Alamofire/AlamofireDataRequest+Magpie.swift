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
}

extension Alamofire.DataRequest {
    static func magpie_DataResponseSerializer() -> DataResponseSerializer<Data> {
        return DataResponseSerializer { request, urlResponse, data, error in
            if let error = error {
                return .failure(error)
            }
            guard let validData = data else {
                if let urlResponse = urlResponse, (200..<300).contains(urlResponse.statusCode) {
                    return .success(Data())
                }
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            return .success(validData)
        }
    }

    public func magpie_responseData(completionHandler: @escaping (DataResponse<Data>) -> Void) -> Self {
        return response(responseSerializer: DataRequest.magpie_DataResponseSerializer(), completionHandler: completionHandler)
    }
}
