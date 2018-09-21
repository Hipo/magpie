//
//  GithubRepo.swift
//  Magpie_Example
//
//  Created by Eray on 20.09.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

struct GithubRepo: Decodable {
    let id: Int
    let fullName: String
    let url: URL
    
    private enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case url
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        fullName = try values.decode(String.self, forKey: CodingKeys.fullName)
        url = try values.decode(URL.self, forKey: .url)
    }
}
