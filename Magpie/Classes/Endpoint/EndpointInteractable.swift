//
//  EndpointInteractable.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

public protocol EndpointInteractable {
    mutating func send()
    mutating func retry()
    mutating func invalidate()
}
