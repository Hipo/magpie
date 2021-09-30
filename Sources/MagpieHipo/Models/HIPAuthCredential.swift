//
//  HIPAuthCredentials.swift
//  Pods
//
//  Created by Karasuluoglu on 14.12.2020.
//

import Foundation
import MacaroonUtils
import MagpieCore

open class HIPAuthCredential:
    AuthCredential,
    APIModel {
    public let token: String
}
