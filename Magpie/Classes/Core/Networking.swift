//
//  Networking.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

public protocol Networking {
    func send(_ request: Request, validateFirst: Bool, then handler: @escaping ResponseHandler) -> TaskConvertible?
    func upload(_ source: EndpointContext.Source, with request: Request, validateFirst: Bool, then handler: @escaping ResponseHandler) -> TaskConvertible?
}
