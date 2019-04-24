//
//  EndpointOperatable.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

public protocol EndpointOperatable: AnyObject, CustomStringConvertible, CustomDebugStringConvertible {
    func send()
    func retry()
    func cancel()
}
