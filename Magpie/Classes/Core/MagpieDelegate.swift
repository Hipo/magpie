//
//  MagpieDelegate.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 20.04.2019.
//

/// <reference>
/// See https://www.swiftbysundell.com/posts/observers-in-swift-part-1

import Foundation

public protocol MagpieDelegate: AnyObject, CustomStringConvertible, CustomDebugStringConvertible {
    func magpie(_ magpie: Magpie, endpointDidFailFromUnauthorizedRequest endpoint: Endpoint)
    func magpie(_ magpie: Magpie, endpoint: Endpoint, didFailFromUnavailableNetwork reason: Error)
    func magpie(_ magpie: Magpie, endpoint: Endpoint, didFailFromUnresponsiveServer reason: Error)
    func magpie(_ magpie: Magpie, networkMonitorDidFailToStart networkMonitor: NetworkMonitor?)
    func magpie(
        _ magpie: Magpie,
        networkMonitor: NetworkMonitor,
        didConnectVia connection: NetworkConnection,
        from oldConnection: NetworkConnection
    )
    func magpie(_ magpie: Magpie, networkMonitor: NetworkMonitor, didDisconnectFrom oldConnection: NetworkConnection)
}

extension MagpieDelegate {
    public var description: String {
        return "A delegate of \(type(of: self))"
    }

    public func magpie(_ magpie: Magpie, endpointDidFailFromUnauthorizedRequest endpoint: Endpoint) { }

    public func magpie(_ magpie: Magpie, endpoint: Endpoint, didFailFromUnavailableNetwork reason: Error) { }

    public func magpie(_ magpie: Magpie, endpoint: Endpoint, didFailFromUnresponsiveServer reason: Error) { }

    public func magpie(_ magpie: Magpie, networkMonitorDidFailToStart networkMonitor: NetworkMonitor?) { }

    public func magpie(
        _ magpie: Magpie,
        networkMonitor: NetworkMonitor,
        didConnectVia connection: NetworkConnection,
        from oldConnection: NetworkConnection
    ) { }

    public func magpie(_ magpie: Magpie, networkMonitor: NetworkMonitor, didDisconnectFrom oldConnection: NetworkConnection) { }
}

class MagpieDelegator {
    weak var delegate: MagpieDelegate?

    init(_ delegate: MagpieDelegate) {
        self.delegate = delegate
    }
}

extension MagpieDelegator: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return delegate?.description ?? "<nil>"
    }
}
