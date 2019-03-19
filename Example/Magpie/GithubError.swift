//
//  GithubError.swift
//  Magpie_Example
//
//  Created by Eray on 4.10.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Magpie

struct GithubError: Mappable {
    let message: String
    let errors: [[String: String]]?
    
    private enum CodingKeys: String, CodingKey {
        case message
        case errors
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        message = try values.decode(String.self, forKey: .message)
        errors = try values.decodeIfPresent([[String: String]].self, forKey: .errors)
    }
}
