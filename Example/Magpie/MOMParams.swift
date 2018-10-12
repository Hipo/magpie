//
//  MOMParams.swift
//  Magpie_Example
//
//  Created by Salih Karasuluoglu on 10.10.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Magpie

enum MOMParamPairKey: String {
    case email = "email"
    case limit = "limit"
    case password = "password"
}

extension MOMParamPairKey: ParamsPairKey {
    var description: String {
        return rawValue
    }
    
    var defaultValue: ParamsPairValue? {
        switch self {
        case .limit:
            return 99999
        default:
            return nil
        }
    }
}
