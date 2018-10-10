//
//  MOMUser.swift
//  Magpie_Example
//
//  Created by Salih Karasuluoglu on 10.10.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Magpie

struct MOMUser {
    let id: Int
    let firstName: String?
    let lastName: String?
    let email: String?
    let accessToken: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Keys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        firstName = try values.decode(String.self, forKey: .firstName)
        lastName = try values.decode(String.self, forKey: .lastName)
        email = try values.decode(String.self, forKey: .email)
        accessToken = try values.decode(String.self, forKey: .accessToken)
    }
}

extension MOMUser: Mappable {
    private enum Keys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case accessToken = "token"
    }
}
