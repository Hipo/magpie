//
//  EndpointOperator.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 2.04.2019.
//

import Foundation

class EndpointOperator {
    var endpoint: Endpoint

    weak var magpie: Magpie?

    init(endpoint: Endpoint, magpie: Magpie) {
        self.endpoint = endpoint
        self.magpie = magpie
    }
}

extension EndpointOperator: EndpointOperatable {
    public var description: String {
        return endpoint.description
    }

    var debugDescription: String {
        return endpoint.debugDescription
    }

    func send() {
        let task = magpie?.send(endpoint)
        endpoint.set(task)
    }

    func retry() {
        let task = magpie?.retry(endpoint)
        endpoint.set(task)
    }

    func cancel() {
        magpie?.cancel(endpoint)
    }
}
