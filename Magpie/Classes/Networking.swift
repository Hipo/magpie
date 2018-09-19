//
//  Networking.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

//public typealias ResponseClosure<C: Codable, E: Error> = (Response<C, E>) -> Void
public typealias ResponseClosure = (Response<Codable, Error>) -> Void

public protocol Networking {
    associatedtype TheRequest: RequestConvertable
    associatedtype TheError: Error
    
    init()
    
    func sendRequest<C: Codable>(
        _ request: Request<Self, C>
        ) -> TheRequest?
    
    func cancelRequest<C: Codable>(_ request: Request<Self, C>)
    func cancelOngoingRequests()
}
