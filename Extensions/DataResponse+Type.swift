//
//  AlamofireExtensions.swift
//  Pods
//
//  Created by Eray on 19.09.2018.
//

import Alamofire

enum DataResponseType {
    case unknown
    case dictionary
    case array
}

extension DataResponse {
    var type: DataResponseType {
        guard let data = self.data else {
            return .unknown
        }
        
        if let _ = data.toJson as? [String: Any] {
            return .dictionary
        }
        
        if let _ = data.toJson as? [[String: Any]] {
            return .array
        }
        
        return .unknown
    }
}
