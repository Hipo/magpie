// Copyright © 2020 hipolabs. All rights reserved.

import Alamofire
import Foundation

/**
 The `Alamofire`-based implementation of `NetworkMonitor` protocol.
 The library is implemented as a stand-alone solution free of how the network monitoring layer
 manages the reachability status and connections. It just requires the passing instance to have a
 certain interface.
 On the other hand, `Alamofire` is one of the most-used networking libraries in the open-source
 community, so `AlamofireNetworkMonitor` is provided as a seperate module for those who like to use.
 On the other hand, we highly recommend `NWNetworkMonitor` instead of this one for iOS12 and later
 versions since it depends on the system built-in `Network` framework.
 */

/// <mark>
/// **NetworkMonitor**
open class AlamofireNetworkMonitor: NetworkMonitor {
    /// An alias for `NetworkReachabilityManager.NetworkReachabilityStatus`
    public typealias ReachabilityStatus = NetworkReachabilityManager.NetworkReachabilityStatus
    /// An alias for `NetworkReachabilityManager.NetworkReachabilityStatus.ConnectionType`
    public typealias ReachabilityConnection = NetworkReachabilityManager.NetworkReachabilityStatus.ConnectionType

    /// The listener to observe the updates from the network monitor.
    public weak var listener: NetworkListener?

    /// The underlying object responsible for monitoring the reachability provided by `Alamofire`.
    public var reachabilityManager: NetworkReachabilityManager?
    /// The last network status just before changing to the current one.
    public var lastStatus: NetworkStatus = .unavailable

    /// Returns the current network status.
    public var currentStatus: NetworkStatus {
        guard let reachabilityManager = reachabilityManager else {
            return .unavailable
        }
        return formNetworkStatus(with: reachabilityManager.status)
    }

    /// Initializes a new object.
    public init() { }

    deinit {
        stop()
    }

    /**

     */
    open func start(on queue: DispatchQueue) {
        if reachabilityManager != nil {
            return
        }

        let reachabilityManager = NetworkReachabilityManager()
        reachabilityManager?.startListening(onQueue: queue) { [weak self] status in
            guard let self = self else { return }

            let newStatus = self.formNetworkStatus(with: status)
            self.listener?.networkMonitor(self, didChangeNetworkStatus: NetworkStatusChange(newStatus, self.lastStatus))
            self.lastStatus = newStatus
        }

        self.reachabilityManager = reachabilityManager
    }

    ///
    open func stop() {
        reachabilityManager?.stopListening()
        reachabilityManager = nil
    }
}

extension AlamofireNetworkMonitor {
    public func formNetworkStatus(with status: ReachabilityStatus) -> NetworkStatus {
        switch status {
        case .unknown:
            return .undetermined
        case .reachable(let connection):
            return .connected(formNetworkConnection(with: connection))
        case .notReachable:
            switch lastStatus {
            case .connected(let connection):
                return .disconnected(connection)
            default:
                return .disconnected(.none)
            }
        }
    }

    public func formNetworkConnection(with connection: ReachabilityConnection) -> NetworkConnection {
        switch connection {
        case .ethernetOrWiFi:
            return .wifi
        case .cellular:
            return .cellular
        }
    }
}
