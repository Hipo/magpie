//
//  RequestPresentable.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 14.09.2018.
//

import Foundation

public protocol RequestProtocol: RequestConvertible, RequestOperatable { }

public protocol RequestConvertible: class {
    var original: RequestProtocol? { get set }

    var base: String { get }
    var path: String { get set }
    var headers: [String: String]? { get set }
    var method: HTTPMethod { get set }
    var parameters: Parameters? { get set }
    var encoding: ParameterEncoding { get set }
    var responseClosure: ResponseClosure { get }
}
