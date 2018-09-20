//
//  RequestOperatable.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

public protocol RequestOperatable: RequestConvertable {
    var path: String { get }
    var headers: [String: String]? { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }

    func send()
    func retry()
    func cancel()
}
