//
//  RequestPresentable.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 14.09.2018.
//

import Foundation

public protocol RequestConvertable {
    var path: String { get }
    var headers: [String: String]? { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
}
