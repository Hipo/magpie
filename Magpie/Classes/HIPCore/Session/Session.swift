//
//  Session.swift
//  Pods
//
//  Created by Karasuluoglu on 9.10.2020.
//

import Foundation

public protocol Session: Printable {
    func verify(_ endpoint: EndpointOperatable)
}
