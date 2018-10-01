//
//  Networking.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

public typealias ResponseClosure = (Response<Decodable, Error>) -> Void

public protocol Networking {
    associatedtype TheRequest: RequestConvertable
    associatedtype TheError: Error
    
    init()
    
    func sendRequest<C: Decodable>(_ request: Request<Self, C>) -> TheRequest?
    func cancelRequest<C: Decodable>(_ request: Request<Self, C>)
    func cancelOngoingRequests()
}

extension Networking {
    func log(
        request: URLRequest? = nil,
        response: HTTPURLResponse? = nil,
        data: Data? = nil,
        value: Any? = nil,
        result: Any
        ) {
        if let request = request {
            print(">>> REQUEST: \(request)")
        }
        
        if let response = response {
            print(">>> RESPONSE: \(response)")
        }
        
        if let data = data {
            print(">>> DATA: \(data)")
        }
        
        if let json = value {
            prettyPrint(json: json)
        }
        
        print(">>> RESULT: \(result)")
    }
    
    private func prettyPrint(json: Any) {
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
            return
        }
        
        guard let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
            return
        }
        
        print(">>> JSON: \(string)")
    }
}
