//
//  MomentAPI.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Magpie

class GithubAPI: Magpie<AlamofireNetworking<GithubError>> {
    
    // MARK: Magpie
    
    override var apiBase: String {
        return "https://api.github.com/"
    }
}

// MARK: Public: Interface

extension GithubAPI {
    
    @discardableResult
    func fetchGithubRepos(withUsername username: String) -> RequestOperatable {
        let path = "users/\(username)/repos"
        
        let request = sendRequest(
            for: GithubRepo.self,
            withPath: path
        ) { response in
            switch response {
            case .success(let repos):
                print(">>> GITHUB REPOS: \(repos)")
            case .failed(let error):
                print(">>> FETCHING ERROR: \(error)")
            }
        }
        
        return request
    }
    
    @discardableResult
    func fetchGithubUser(withUsername username: String) -> RequestOperatable {
        let path = "users/\(username)"
        
        let request = sendRequest(
            for: GithubUser.self,
            withPath: path
        ) { (response) in
            switch response {
            case .success(let user):
                print(">>> GITHUB User: \(user)")
            case .failed(let error):
                print(">>> FETCHING ERROR: \(error)")                
            }
        }
        
        return request
    }
    
    func cancelGithubReposFetchRequest(withUsername username: String) {
        let path = "users/\(username)/repos"

        cancelRequest(withPath: path)
    }
}
