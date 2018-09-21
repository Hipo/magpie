//
//  Networking.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

public typealias ResponseClosure = (Response<Decodable, Error>) -> Void

public protocol Networking {
    associatedtype TheRequest: RequestConvertable
    associatedtype TheError: Error
    
    init()
    
    func sendRequest<C: Decodable>(_ request: Request<Self, C>) -> TheRequest?
    func cancelRequest<C: Decodable>(_ request: Request<Self, C>)
    func cancelOngoingRequests()
}
