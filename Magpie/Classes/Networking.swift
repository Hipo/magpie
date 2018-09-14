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
    
    func sendRequest(_ request: Request<Self>) -> TheRequest

    func cancelRequest(_ request: Request<Self>)
    func cancelOngoingRequests()
}
