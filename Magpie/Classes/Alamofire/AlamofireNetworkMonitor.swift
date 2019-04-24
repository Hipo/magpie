//
//  AlamofireNetworkMonitor.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 18.04.2019.
//

import Alamofire
import Foundation

open class AlamofireNetworkMonitor: NetworkMonitor {
    public var watcher: NetworkStatusChangeWatcher?

    public var currentStatus: NetworkStatus {
        guard let reachabilityManager = reachabilityManager else {
            return .unavailable
        }
        return networkStatus(for: reachabilityManager.networkReachabilityStatus)
    }

    private var reachabilityManager: NetworkReachabilityManager?
    public var lastStatus: NetworkStatus = .unavailable

    public init() { }

    deinit {
        stop()
    }

    public func start(on queue: DispatchQueue) throws {
        if reachabilityManager != nil {
            return
        }
        guard let reachabilityManager = NetworkReachabilityManager() else {
            throw Error.networkMonitoring(.notStarted)
        }
        reachabilityManager.listener = { [weak self] status in
            guard let self = self else {
                return
            }
            let last = self.lastStatus
            let new = self.networkStatus(for: status)

            self.watcher?((new, last))

            self.lastStatus = new
        }
        reachabilityManager.listenerQueue = queue
        reachabilityManager.startListening()

        self.reachabilityManager = reachabilityManager
    }

    public func stop() {
        reachabilityManager?.stopListening()
        reachabilityManager = nil
    }

    private func networkStatus(for reachabilityStatus: NetworkReachabilityManager.NetworkReachabilityStatus) -> NetworkStatus {
        switch reachabilityStatus {
        case .unknown:
            return .undetermined
        case .reachable(let connectionType):
            return .connected(networkConnection(for: connectionType))
        case .notReachable:
            switch lastStatus {
            case .connected(let connection):
                return .disconnected(connection)
            default:
                return .disconnected(.none)
            }
        }
    }

    /// <warning>
    /// NetworkReachabilityManager.ConnectionType doesn't cover the all NetworkConnection cases correctly. We ignored this fact
    /// for the sake of using the Apple-supported NWNetworkMonitor's capabilities properly. After dropping support to iOS 11 and
    /// below versions, we will delete this class.
    private func networkConnection(for reachabilityConnectionType: NetworkReachabilityManager.ConnectionType) -> NetworkConnection {
        switch reachabilityConnectionType {
        case .ethernetOrWiFi:
            return .wifi
        case .wwan:
            return .cellular
        }
    }
}
