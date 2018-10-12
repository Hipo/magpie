//
//  MOMAPI.swift
//  Magpie_Example
//
//  Created by Salih Karasuluoglu on 10.10.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Magpie

class MOMAPI: Magpie<AlamofireNetworking> {
}

extension MOMAPI {
    @discardableResult
    func authenticate(with email: String, password: String, handler: ResponseHandler<MOMUser>?) -> EndpointOperatable {
        return send(
            Endpoint<MOMUser>("/api/profiles/authenticate/")
                .httpMethod(.post)
                .body([
                    .custom(key: MOMParamPairKey.email, value: email),
                    .custom(key: MOMParamPairKey.password, value: password)
                ])
                .handler(handler)
        )
    }
}
