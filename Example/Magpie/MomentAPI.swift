//
//  MomentAPI.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Magpie

class MomentAPI: Magpie<AlamofireNetworking> {
    // MARK: Magpie
    override var apiBase: String {
        return "https://staging.moment.com/api"
    }
}

// MARK: Public:Interface
extension MomentAPI {
    @discardableResult
    func authenticate(withEmail email: String, password: String) -> RequestOperatable {
        return generateAndSendRequest()
    }
}
