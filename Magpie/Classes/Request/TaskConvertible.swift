//
//  TaskConvertible.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Foundation

public protocol TaskConvertible: AnyObject, CustomStringConvertible, CustomDebugStringConvertible {
    var underlyingTask: URLSessionTask? { get }

    func cancelImmediately()
}

extension TaskConvertible {
    public var description: String {
        return underlyingTask.absoluteDescription
    }

    public var debugDescription: String {
        return underlyingTask.absoluteDebugDescription
    }
}
