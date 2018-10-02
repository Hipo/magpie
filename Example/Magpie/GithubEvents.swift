//
//  GithubEvents.swift
//  Magpie_Example
//
//  Created by Eray on 2.10.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

struct GithubUser: Decodable {
    let id: Int
    let login: String
    let url: URL
    let repos: Int
    let followers: Int
    let following: Int
    
    private enum CodingKeys: String, CodingKey {
        case id
        case login
        case url
        case repos = "public_repos"
        case followers
        case following
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        login = try values.decode(String.self, forKey: .login)
        url = try values.decode(URL.self, forKey: .url)
        repos = try values.decode(Int.self, forKey: .repos)
        followers = try values.decode(Int.self, forKey: .followers)
        following = try values.decode(Int.self, forKey: .following)
    }
}
