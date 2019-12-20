//
//  EndpointOperatable.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

public protocol EndpointOperatable: Printable {
    var request: Request { get }

    func send()
    func retry()
    func cancel()
}
