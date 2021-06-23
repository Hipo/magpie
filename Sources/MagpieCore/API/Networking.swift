//
//  Networking.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

public protocol Networking {
    typealias ResponseHandler = (Response) -> Void

    func send(_ request: Request, validateResponse: Bool, queue: DispatchQueue, using handler: @escaping ResponseHandler) -> TaskConvertible?
    func upload(_ source: EndpointType.Source, with request: Request, validateResponse: Bool, queue: DispatchQueue, using handler: @escaping ResponseHandler) -> TaskConvertible?
    func upload(_ form: MultipartForm, with request: Request, validateResponse: Bool, queue: DispatchQueue, using handler: @escaping ResponseHandler) -> TaskConvertible?
}
