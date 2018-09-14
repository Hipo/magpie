//
//  RequestOperatable.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

public protocol RequestOperatable: RequestConvertable {
    func send()
    func retry()
    func cancel()
}
