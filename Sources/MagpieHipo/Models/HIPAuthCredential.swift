//
//  HIPAuthCredentials.swift
//  Pods
//
//  Created by Karasuluoglu on 14.12.2020.
//

import Foundation
import MacaroonUtils

open class HIPAuthCredential: AuthCredential {
    public var debugData: Data?
    public let token: String

    public required init(
        _ apiModel: APIModel
    ) {
        self.token = apiModel.token
    }
}

extension HIPAuthCredential {
    public struct APIModel: JSONModel {
        let token: String
    }
}
