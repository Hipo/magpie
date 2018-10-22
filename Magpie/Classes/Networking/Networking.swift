//
//  Networking.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

public enum DataResponse {
    case success(Data?)
    case failure(Error)
}

public protocol Networking {
    typealias DataResponseHandler = (DataResponse) -> Void

    init()
    
    func send<ObjectType>(
        _ request: Request<ObjectType>,
        handler: DataResponseHandler?)
        -> TaskCancellable?
    where ObjectType: Mappable

    func cancel<ObjectType>(_ request: Request<ObjectType>) where ObjectType: Mappable
    func cancelAll()
}

// TODO: Refactor logging method.
//extension Networking {
//    func log(
//        request: URLRequest? = nil,
//        response: HTTPURLResponse? = nil,
//        data: Data? = nil,
//        value: Any? = nil,
//        result: Any
//        ) {
//        if let request = request {
//            print(">>> REQUEST: \(request)")
//        }
//
//        if let response = response {
//            print(">>> RESPONSE: \(response)")
//        }
//
//        if let data = data {
//            print(">>> DATA: \(data)")
//        }
//
//        if let json = value {
//            prettyPrint(json: json)
//        }
//
//        print(">>> RESULT: \(result)")
//    }
//
//    private func prettyPrint(json: Any) {
//        guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
//            return
//        }
//
//        guard let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
//            return
//        }
//
//        print(">>> JSON: \(string)")
//    }
//}
