//
//  NWNetworkMonitor.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 18.04.2019.
//

import Foundation
import Network

@available (iOS 12.0, *)
open class NWNetworkMonitor: NetworkMonitor {
    public var watcher: NetworkStatusChangeWatcher?

    public var currentStatus: NetworkStatus {
        guard let currentPath = pathMonitor?.currentPath else {
            return .unavailable
        }
        return networkStatus(for: currentPath)
    }

    private var pathMonitor: NWPathMonitor?
    private var lastStatus: NetworkStatus = .unavailable

    public init() { }

    deinit {
        stop()
    }

    public func start(on queue: DispatchQueue) throws {
        if pathMonitor != nil {
            return
        }
        let pathMonitor = NWPathMonitor()
        pathMonitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else {
                return
            }
            let last = self.lastStatus
            let new = self.networkStatus(for: path)

            self.watcher?((new, last))

            self.lastStatus = new
        }
        pathMonitor.start(queue: queue)

        self.pathMonitor = pathMonitor
    }

    public func stop() {
        pathMonitor?.cancel()
        pathMonitor = nil
    }

    private func networkStatus(for path: NWPath) -> NetworkStatus {
        switch path.status {
        case .requiresConnection:
            return .undetermined
        case .satisfied:
            return .connected(networkConnection(for: path))
        case .unsatisfied:
            switch lastStatus {
            case .connected(let connection):
                return .disconnected(connection)
            default:
                return .disconnected(.none)
            }
        @unknown default:
            return .undetermined
        }
    }

    private func networkConnection(for path: NWPath) -> NetworkConnection {
        if path.status != .satisfied {
            return .none
        }
        if path.usesInterfaceType(.wifi) {
            return .wifi
        }
        if path.usesInterfaceType(.wiredEthernet) {
            return .wiredEthernet
        }
        if path.usesInterfaceType(.cellular) {
            return .cellular
        }
        return .other
    }
}
