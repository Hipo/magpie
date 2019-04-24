//
//  Alamofire+TaskConvertible.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Alamofire
import Foundation

extension Alamofire.DataRequest: TaskConvertible {
    public var underlyingTask: URLSessionTask? {
        return task
    }
}
