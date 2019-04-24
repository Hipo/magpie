//
//  NetworkMonitor.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 18.04.2019.
//

import Foundation

public protocol NetworkMonitor: AnyObject, CustomStringConvertible, CustomDebugStringConvertible {
    typealias NetworkStatusChange = (new: NetworkStatus, old: NetworkStatus)
    typealias NetworkStatusChangeWatcher = (NetworkStatusChange) -> Void

    /// <warning>
    /// The watcher shouldn't be set explicitly if the network monitor will be passed to the Magpie instance.
    var watcher: NetworkStatusChangeWatcher? { get set }
    var currentStatus: NetworkStatus { get }

    func start(on queue: DispatchQueue) throws
    func stop()
}

extension NetworkMonitor {
    public var isConnected: Bool {
        if case NetworkStatus.connected = currentStatus {
            return true
        }
        return false
    }
}

extension NetworkMonitor {
    public var description: String {
        return "Currently \(currentStatus.description) with \(watcher == nil ? "no watcher" : "a watcher") added."
    }
}

public enum NetworkConnection: Equatable {
    case none
    case wifi
    case wiredEthernet
    case cellular
    case other
}

extension NetworkConnection: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .none:
            return "no connection"
        case .wifi:
            return "wifi"
        case .wiredEthernet:
            return "wired ethernet"
        case .cellular:
            return "cellular"
        case .other:
            return "unknown connection"
        }
    }
}

public enum NetworkStatus: Equatable {
    case unavailable
    case undetermined
    case connected(NetworkConnection)
    case disconnected(NetworkConnection)
}

extension NetworkStatus {
    var isConnected: Bool {
        if case NetworkStatus.connected = self {
            return true
        }
        return false
    }

    var connection: NetworkConnection {
        switch self {
        case .unavailable,
             .undetermined:
            return .none
        case .connected(let connection):
            return connection
        case .disconnected(let connection):
            return connection
        }
    }
}

extension NetworkStatus: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .unavailable:
            return "<unavailable>"
        case .undetermined:
            return "<undetermined>"
        case .connected(let connection):
            return "connected via \(connection.description)"
        case .disconnected(let connection):
            return "disconnected from \(connection.description)"
        }
    }
}
