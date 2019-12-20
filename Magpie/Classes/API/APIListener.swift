//
//  APIListener.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 20.04.2019.
//

/// <reference> https://www.swiftbysundell.com/posts/observers-in-swift-part-1

import Foundation

public protocol APIListener: AnyObject, Printable {
    func api(_ api: API, endpointDidFailFromUnauthorizedRequest endpoint: EndpointOperatable) /// <note> Called for 401
    func api(_ api: API, endpoint: EndpointOperatable, didFailFromUnavailableNetwork error: NetworkError)
    func api(_ api: API, endpoint: EndpointOperatable, didFailFromDefectiveClient error: HTTPError) /// <note> Called for all 4xx excluding 401
    func api(_ api: API, endpoint: EndpointOperatable, didFailFromUnresponsiveServer error: HTTPError) /// <note> Called for all 5xx
    func api(_ api: API, networkMonitor: NetworkMonitor, didConnectVia connection: NetworkConnection, from oldConnection: NetworkConnection)
    func api(_ api: API, networkMonitor: NetworkMonitor, didDisconnectFrom oldConnection: NetworkConnection)
    func api(_ api: API, networkMonitorDidEnterBackground networkMonitor: NetworkMonitor)
}

extension APIListener {
    public func api(_ api: API, endpointDidFailFromUnauthorizedRequest endpoint: EndpointOperatable) { }
    public func api(_ api: API, endpoint: EndpointOperatable, didFailFromUnavailableNetwork error: NetworkError) { }
    public func api(_ api: API, endpoint: EndpointOperatable, didFailFromDefectiveClient error: HTTPError) { }
    public func api(_ api: API, endpoint: EndpointOperatable, didFailFromUnresponsiveServer error: HTTPError) { }
    public func api(_ api: API, networkMonitor: NetworkMonitor, didConnectVia connection: NetworkConnection, from oldConnection: NetworkConnection) { }
    public func api(_ api: API, networkMonitor: NetworkMonitor, didDisconnectFrom oldConnection: NetworkConnection) { }
    func api(_ api: API, networkMonitorDidEnterBackground networkMonitor: NetworkMonitor) { }
}

extension APIListener {
    /// <mark> CustomStringConvertible
    public var description: String {
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
    /// <mark> CustomStringConvertible
    var description: String {
        if let listener = listener {
            return "\(type(of: listener))"
        }
        return "<nil>"
    }
}
