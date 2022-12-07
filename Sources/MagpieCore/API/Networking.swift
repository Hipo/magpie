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
    func download(_ request: Request, to destination: EndpointType.DownloadDestination, validateResponse: Bool, queue: DispatchQueue, using handler: @escaping ResponseHandler) -> TaskConvertible?
    func upload(_ request: MagpieCore.Request, from source: EndpointType.UploadSource, validateResponse: Bool, queue: DispatchQueue, using handler: @escaping ResponseHandler) -> TaskConvertible?
    func upload(_ request: MagpieCore.Request, from form: MultipartForm, validateResponse: Bool, queue: DispatchQueue, using handler: @escaping ResponseHandler) -> TaskConvertible?
}
