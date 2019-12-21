//
//  EndpointOperatable.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

public protocol EndpointOperatable: Printable {
    var request: Request { get }

    func set(additionalHeaders: Headers)
    func send()
    func retry()
    func cancel()
}

extension EndpointOperatable {
    public func set(additionalHeader: Header) {
        set(additionalHeaders: [additionalHeader])
    }
}
