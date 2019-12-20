//
//  APIInterceptor.swift
//  Magpie
//
//  Created by Karasuluoglu on 19.12.2019.
//

import Foundation

public protocol APIInterceptor: Printable {
    func intercept(_ endpoint: EndpointOperatable)
}
