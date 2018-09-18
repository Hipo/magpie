//
//  Networking.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

public protocol Networking {
    associatedtype TheRequest: RequestConvertable
    
    init()
    
    func sendRequest<C: Codable>(_ request: Request<Self, C>) -> TheRequest
    func cancelRequest<C: Codable>(_ request: Request<Self, C>)
    func cancelOngoingRequests()
}
