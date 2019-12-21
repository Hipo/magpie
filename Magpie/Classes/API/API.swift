//
//  API.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

open class API {
    public var base: String

    open var interceptor: APIInterceptor?

    open var notifiesListenersWhenEndpointsFailedFromUnavailableNetwork = false
    open var notifiesListenersWhenEndpointsFailedFromDefectiveClient = false
    open var notifiesListenersWhenEndpointsFailedFromUnresponsiveServer = false

    public let networking: Networking
    public let networkMonitor: NetworkMonitor?

    lazy var storage = TaskStorage()
    lazy var logger = Logger()

    var listens: [ObjectIdentifier: APIListen] = [:]
    var networkMonitoringObservers: [NSObjectProtocol] = []

    public required init(
        base: String,
        networking: Networking,
        networkMonitor: NetworkMonitor? = nil
    ) {
        self.base = base
        self.networking = networking
        self.networkMonitor = networkMonitor

        if networkMonitor != nil {
            allowNetworkMonitoring()
        }
    }

    deinit {
        cancelEndpoints()
        cancelNetworkMonitoring()
    }
}

extension API {
    /// <note> This method always overrides the logs to be shown in console.
    public func showLogsInConsole(_ logs: [Logs]) {
        logger.logs = logs
    }

    public func hideLogsInConsole() {
        logger.logs = []
    }
}

extension API {
    public func cancelEndpoints(with path: String) {
        storage.cancelAndDeleteAll(with: path)
    }

    public func cancelEndpoints(relativeTo path: String) {
        storage.cancelAndDeleteAll(relativeTo: path)
    }
    
    public func cancelEndpoints() {
        storage.cancelAndDeleteAll()
    }
}

extension API {
    func send(_ endpoint: Endpoint) -> TaskConvertible? {
        logger.log(endpoint.request)

        let responseHandler: Networking.ResponseHandler = { [weak self] response in
            self?.storage.delete(for: endpoint)
            self?.forward(response, for: endpoint)
            self?.logger.log(response)
        }

        if let task = forward(endpoint, onReversed: responseHandler) {
            storage.add(task, for: endpoint)
            return task
        }
        return nil
    }

    private func forward(_ endpoint: Endpoint, onReversed responseHandler: @escaping Networking.ResponseHandler) -> TaskConvertible? {
        interceptor?.intercept(endpoint)

        switch endpoint.type {
        case .data:
            return networking.send(endpoint.request, validateResponse: endpoint.validatesResponseBeforeCompletion, onReceived: responseHandler)
        case .upload(let src):
            return networking.upload(src, with: endpoint.request, validateResponse: endpoint.validatesResponseBeforeCompletion, onCompleted: responseHandler)
        }
    }

    private func forward(_ response: Response, for endpoint: Endpoint) {
        guard let error = response.error else {
            endpoint.forward(response)
            return
        }
        if let httpError = error as? HTTPError {
            forward(response, for: endpoint, onFailedFrom: httpError)
            return
        }
        if let networkError = error as? NetworkError {
            forward(response, for: endpoint, onFailedFrom: networkError)
            return
        }
        endpoint.forward(response)
    }

    private func forward(_ response: Response, for endpoint: Endpoint, onFailedFrom error: HTTPError) {
        switch error.reason {
        case .unauthorized:
            if endpoint.notifiesListenersOnFailedFromUnauthorizedRequest {
                forward(response, for: endpoint) { $0.api(self, endpointDidFailFromUnauthorizedRequest: endpoint) }
            } else {
                endpoint.forward(response)
            }
        case .badRequest,
             .notFound,
             .forbidden,
             .client:
            if endpoint.notifiesListenersOnFailedFromDefectiveClient {
                forward(response, for: endpoint) { $0.api(self, endpoint: endpoint, didFailFromDefectiveClient: error) }
            } else {
                endpoint.forward(response)
            }
        case .notImplemented,
             .serviceUnavailable,
             .server:
            if endpoint.notifiesListenersOnFailedFromUnresponsiveServer {
                forward(response, for: endpoint) { $0.api(self, endpoint: endpoint, didFailFromUnresponsiveServer: error) }
            } else {
                endpoint.forward(response)
            }
        default:
            endpoint.forward(response)
        }
    }

    private func forward(_ response: Response, for endpoint: Endpoint, onFailedFrom error: NetworkError) {
        switch error.reason {
        case .notConnectedToInternet:
            if endpoint.notifiesListenersOnFailedFromUnavailableNetwork {
                forward(response, for: endpoint) { $0.api(self, endpoint: endpoint, didFailFromUnavailableNetwork: error) }
            } else {
                endpoint.forward(response)
            }
        case .cancelled:
            if !endpoint.ignoresResponseOnCancelled {
                endpoint.forward(response)
            }
        default:
            endpoint.forward(response)
        }
    }

    private func forward(_ response: Response, for endpoint: Endpoint, afterNotifyingListeners notifier: ListenerNotifier) {
        notifyListeners(notifier)

        if !endpoint.ignoresResponseWhenListenersNotified {
            endpoint.forward(response)
        }
    }
}

extension API {
    public func startNetworkMonitoring() {
        if let nm = networkMonitor {
            nm.listener = self
            nm.start(on: DispatchQueue(label: "com.hipo.magpie.queue.networkmonitoring"))
        } else {
            removeNetworkMonitoringObservers()

            logger.log("Network monitoring is disabled", .networkMonitoring)
        }
    }

    public func stopNetworkMonitoring() {
        if let nm = networkMonitor {
            nm.stop()
        } else {
            removeNetworkMonitoringObservers()
        }
    }

    func allowNetworkMonitoring() {
        startNetworkMonitoring()
        addNetworkMonitoringObservers()
    }

    func cancelNetworkMonitoring() {
        stopNetworkMonitoring()
        removeNetworkMonitoringObservers()
    }

    func addNetworkMonitoringObservers() {
        let startObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] _ in
            self?.startNetworkMonitoring()
        }
        let stopObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] _ in
            self?.stopNetworkMonitoring()

            if let self = self,
               let nm = self.networkMonitor {
                nm.listener?.networkMonitor(nm, didChangeNetworkStatus: NetworkStatusChange(.suspended, .undetermined))
            }
        }

        networkMonitoringObservers = [startObserver, stopObserver]
    }

    func removeNetworkMonitoringObservers() {
        for observer in networkMonitoringObservers {
            NotificationCenter.default.removeObserver(observer)
        }
        networkMonitoringObservers = []
    }
}


extension API {
    typealias ListenerNotifier = (APIListener) -> Void

    public func addListener(_ listener: APIListener) {
        let id = ObjectIdentifier(listener)
        listens[id] = APIListen(listener)
    }

    public func removeListener(_ listener: APIListener) {
        let id = ObjectIdentifier(listener)
        listens[id] = nil
    }

    public func removeAllListeners() {
        listens.removeAll()
    }

    func notifyListeners(_ notifier: ListenerNotifier) {
        for (id, listen) in listens {
            if let listener = listen.listener {
                notifier(listener)
            } else {
                listens[id] = nil
            }
        }
    }
}

extension API: NetworkListener {
    public func networkMonitor(_ networkMonitor: NetworkMonitor, didChangeNetworkStatus change: NetworkStatusChange) {
        DispatchQueue.main.async {
            self.notifyListeners { listener in
                switch change.new {
                case .unavailable:
                    break
                case .connected(let connection):
                    listener.api(self, networkMonitor: networkMonitor, didConnectVia: connection, from: change.old.connection)
                case .undetermined,
                     .disconnected:
                    listener.api(self, networkMonitor: networkMonitor, didDisconnectFrom: change.old.connection)
                case .suspended:
                    listener.api(self, networkMonitorDidEnterBackground: networkMonitor)
                }
            }
            self.logger.log(networkMonitor)
        }
    }
}

extension API: Printable {
    /// <mark> CustomStringConvertible
    public var description: String {
        return """
        \(base)
        \(interceptor?.description ?? "no interceptor")
        ongoing tasks
        \(storage.description)
        listeners
        [\(listens.map({ $0.value.description }).joined(separator: ","))]
        """
    }
}
