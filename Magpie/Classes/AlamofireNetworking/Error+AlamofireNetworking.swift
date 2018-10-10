//
//  Error+AlamofireNetworking.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 9.10.2018.
//

import Alamofire
import Foundation

extension Error {
    init(afError: AFError, responseData: Data?) {
        guard let code = afError.responseCode else {
            self = .unknown(afError.underlyingError)
            return
        }
        self = Error.error(from: (
            statusCode: code,
            underlyingError: afError.underlyingError,
            responseData: responseData
            )
        )
    }
}
