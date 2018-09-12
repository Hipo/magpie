//
//  MagpieExampleApi.swift
//  Magpie_Example
//
//  Created by Eray on 12.09.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Magpie

class MagpieExampleApi: API {    
    @discardableResult
    func fetchGithubRepos(
        of username: String,
        then handler: (Response<GithubRepo, GithubRepoFetchError>) -> ()) -> GithubFetchRequest {
        
        return quickRequest(Path.repos.url, HTTPMethod.get)
    }    
}

class GithubFetchRequest: MagpieRequest {
    typealias TheAPI = API
    
    var httpMethod: HTTPMethod
    var url: URL

    var api: API?
        
    required init(httpMethod: HTTPMethod, url: URL) {
        self.httpMethod = httpMethod
        self.url = url
    }
    
    func send() {

    }
    
    func cancel() {

    }
    
    func retry() {

    }
}

class GithubRepo: Codable {
    var id = 0
}

enum GithubRepoFetchError: Error {
    
}
