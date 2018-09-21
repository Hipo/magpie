//
//  MomentAPI.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Magpie

class GithubAPI: Magpie<AlamofireNetworking> {
    
    // MARK: Magpie
    
    override var apiBase: String {
        return "https://api.github.com/"
    }
}

// MARK: Public: Interface

extension GithubAPI {
    
    @discardableResult
    func fetchGithubRepos(withUsername username: String) -> RequestOperatable {
        let request = sendRequest(
            for: GithubRepo.self,
            withPath: "users/\(username)/repos") { response in
                switch response {
                case .success(let repos):
                    print(">>> GITHUB REPO: \(repos)")
                case .failed(let error):
                    print(">>> FETCHING ERROR: \(error)")
                }
        }
        
        return request
    }
}
