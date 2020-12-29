//
//  APIListener.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 20.04.2019.
//

/// <reference> https://www.swiftbysundell.com/posts/observers-in-swift-part-1

import Foundation

public protocol APIListener: AnyObject, Printable {
    func endpointDidFailFromUnauthorizedRequest(_ endpoint: EndpointOperatable) /// <note> Called for 401
    func endpoint(_ endpoint: EndpointOperatable, didFailFromUnavailableNetwork error: ConnectionError)
    func endpoint(_ endpoint: EndpointOperatable, didFailFromDefectiveClient error: HTTPError) /// <note> Called for all 4xx excluding 401
    func endpoint(_ endpoint: EndpointOperatable, didFailFromUnresponsiveServer error: HTTPError) /// <note> Called for all 5xx
    func networkDidConnect(via connection: NetworkConnection, from oldConnection: NetworkConnection)
    func networkDidDisconnect(from oldConnection: NetworkConnection)
    func networkDidSuspendOnBackground()
}

extension APIListener {
    public func endpointDidFailFromUnauthorizedRequest(_ endpoint: EndpointOperatable) { }
    public func endpoint(_ endpoint: EndpointOperatable, didFailFromUnavailableNetwork error: ConnectionError) { }
    public func endpoint(_ endpoint: EndpointOperatable, didFailFromDefectiveClient error: HTTPError) { }
    public func endpoint(_ endpoint: EndpointOperatable, didFailFromUnresponsiveServer error: HTTPError) { }
    public func networkDidConnect(with connection: NetworkConnection, from oldConnection: NetworkConnection) { }
    public func networkDidDisconnect(from oldConnection: NetworkConnection) { }
    public func networkDidSuspendOnBackground() { }
}

extension APIListener {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "Listener of \(type(of: self))"
    }
}

class APIListen {
    weak var listener: APIListener?

    init(_ listener: APIListener) {
        self.listener = listener
    }
}

extension APIListen: Printable {
    /// <mark> CustomDebugStringConvertible
    var debugDescription: String {
        if let listener = listener {
            return "\(type(of: listener))"
        }
        return "<nil>"
    }
}
