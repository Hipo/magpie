//
//  Request.swift
//  Magpie
//
//  Created by Eray on 12.09.2018.
//

public protocol MagpieRequest {
    associatedtype TheAPI: API//<Self>
    
    var httpMethod: HTTPMethod { get set }
    var url: URL { get set }
    
    var api: TheAPI? { get set }
    
    init(httpMethod: HTTPMethod, url: URL)
    
    func send()
    func cancel()
    func retry()
}
