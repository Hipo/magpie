//
//  Magpie.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

open class Magpie {
    public var sharedQueryEncodingStrategy = QueryEncodingStrategy()
    public var sharedJsonBodyEncodingStrategy = JSONBodyEncodingStrategy()
    public var sharedHttpHeaders = Headers.default
    public var sharedModelDecodingStrategy = ModelDecodingStrategy()
    public var sharedErrorModelDecodingStrategy = ModelDecodingStrategy()

    public var base: String
    public var logFilter: LogFilter {
        get {
            return logger.filter
        }
        set {
            logger.filter = newValue
        }
    }
    /// Returns valid internet connection
    public var isConnectedToInternet: Bool {
        return networkMonitor?.isConnectedToInternet ?? true
    }
    
    /// Returns valid network connection
    public var isConnected: Bool {
        return networkMonitor?.isConnected ?? true
    }

    var taskBin = TaskBin()

    var delegators: [ObjectIdentifier: MagpieDelegator] = [:]
    var networkMonitorRunCycleObservers: [NSObjectProtocol] = []

    var logger = Logger()

    let networking: Networking
    let networkMonitor: NetworkMonitor?

    public required init(
        base: String,
        networking: Networking,
        networkMonitor: NetworkMonitor? = nil
    ) {
        self.base = base
        self.networking = networking
        self.networkMonitor = networkMonitor

        if let nm = networkMonitor {
            prepareForNetworkMonitoring(nm)
            startNetworkMonitoring()
        }
    }

    deinit {
        cancelAllEndpoints()
        cancelNetworkMonitoring()
    }
}

extension Magpie {
    public func cancelEndpoints(with path: Path) {
        taskBin.cancelAndRemoveAll(for: path)
    }

    public func cancelEndpoints(relativeTo path: Path) {
        taskBin.cancelAndRemoveAll(relativeTo: path)
    }
    
    public func cancelAllEndpoints() {
        taskBin.cancelAndRemoveAll()
    }
}

extension Magpie {
    public func addDelegate(_ delegate: MagpieDelegate) {
        let id = ObjectIdentifier(delegate)
        delegators[id] = MagpieDelegator(delegate)
    }

    public func removeDelegate(_ delegate: MagpieDelegate) {
        let id = ObjectIdentifier(delegate)
        delegators.removeValue(forKey: id)
    }

    public func removeAllDelegates() {
        delegators.removeAll()
    }

    func notifyDelegates(_ notifier: (MagpieDelegate) -> Void) {
        for (id, delegator) in delegators {
            if let delegate = delegator.delegate {
                notifier(delegate)
            } else {
                delegators.removeValue(forKey: id)
            }
        }
    }
}

extension Magpie {
    func send(_ endpoint: Endpoint) -> TaskConvertible? {
        endpoint.setIfNeeded(base)
        endpoint.setIfNeeded(sharedQueryEncodingStrategy)
        endpoint.setIfNeeded(sharedJsonBodyEncodingStrategy)
        endpoint.setIfNeeded(sharedHttpHeaders)
        endpoint.setModelDecodingStrategyIfNeeded(sharedModelDecodingStrategy)
        endpoint.setErrorModelDecodingStrategyIfNeeded(sharedErrorModelDecodingStrategy)
        return retry(endpoint)
    }

    func retry(_ endpoint: Endpoint) -> TaskConvertible? {
        let handler: ResponseHandler = { [weak self] response in
            guard let self = self else {
                return
            }
            self.taskBin.removeTask(for: endpoint)
            self.process(response, for: endpoint)

            self.logger.log(response)
        }
        let task: TaskConvertible?

        switch endpoint.context {
        case .data:
            task = networking.send(endpoint.request, validateFirst: endpoint.validatesResponseFirstWhenReceived, then: handler)
        case .upload(let src):
            task = networking.upload(src, with: endpoint.request, validateFirst: endpoint.validatesResponseFirstWhenReceived, then: handler)
        }

        logger.log(endpoint)

        if let someTask = task {
            taskBin.save(someTask, for: endpoint)
        }
        return task
    }

    func process(_ response: Response, for endpoint: Endpoint) {
        guard let errorContainer = response.errorContainer else {
            endpoint.advance(response)
            return
        }
        let error = errorContainer.decoded()

        switch error {
        case .unauthorized:
            let shouldNotifyDelegates = endpoint.notifiesDelegatesWhenFailedFromUnauthorizedRequest
            process(response, for: endpoint, afterNotifyingDelegatesIfNeeded: shouldNotifyDelegates) { delegate in
                delegate.magpie(self, endpointDidFailFromUnauthorizedRequest: endpoint)
            }
        case .notImplemented,
             .serviceUnavailable,
             .server:
            let shouldNotifyDelegates = endpoint.notifiesDelegatesWhenFailedFromUnresponsiveServer
            process(response, for: endpoint, afterNotifyingDelegatesIfNeeded: shouldNotifyDelegates) { delegate in
                delegate.magpie(self, endpoint: endpoint, didFailFromUnresponsiveServer: error)
            }
        case .networkUnavailable:
            let shouldNotifyDelegates = endpoint.notifiesDelegatesWhenFailedFromUnavailableNetwork
            process(response, for: endpoint, afterNotifyingDelegatesIfNeeded: shouldNotifyDelegates) { delegate in
                delegate.magpie(self, endpoint: endpoint, didFailFromUnavailableNetwork: error)
            }
        case .cancelled:
            if !endpoint.ignoresResultWhenCancelled {
                endpoint.advance(response)
            }
        default:
            endpoint.advance(response)
        }
    }

    func process(
        _ response: Response,
        for endpoint: Endpoint,
        afterNotifyingDelegatesIfNeeded shouldNotifyDelegates: Bool,
        notifier: (MagpieDelegate) -> Void
    ) {
        if shouldNotifyDelegates {
            notifyDelegates { delegate in
                notifier(delegate)
            }
            if !endpoint.ignoresResultWhenDelegatesNotified {
                endpoint.advance(response)
            }
            return
        }
        endpoint.advance(response)
    }

    func cancel(_ endpoint: Endpoint) {
        endpoint.task?.cancel()
    }
}

extension Magpie {
    public func startNetworkMonitoring() {
        let notifyDelegatesWhenFailed = { [unowned self] in
            self.notifyDelegates { delegate in
                delegate.magpie(self, networkMonitorDidFailToStart: self.networkMonitor)
            }
        }
        do {
            guard let networkMonitor = networkMonitor else {
                notifyDelegatesWhenFailed()
                terminateNetworkMonitorRunCycleObservers()

                logger.log("Network monitoring is disabled automatically because of an unknown failure.", .networkMonitoring)

                return
            }
            try networkMonitor.start(on: DispatchQueue(label: "com.hipo.magpie.queue.networkMonitoring"))
            createNetworkMonitorRunCycleObservers()
        } catch {
            notifyDelegatesWhenFailed()
        }
    }

    public func stopNetworkMonitoring() {
        guard let networkMonitor = networkMonitor else {
            terminateNetworkMonitorRunCycleObservers()
            return
        }
        let lastStatus = networkMonitor.currentStatus

        networkMonitor.stop()
        networkMonitor.watcher?((.unavailable, lastStatus))
    }

    func createNetworkMonitorRunCycleObservers() {
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
        }

        networkMonitorRunCycleObservers = [startObserver, stopObserver]
    }

    func terminateNetworkMonitorRunCycleObservers() {
        if networkMonitorRunCycleObservers.isEmpty {
            return
        }
        for observer in networkMonitorRunCycleObservers {
            NotificationCenter.default.removeObserver(observer)
        }
        networkMonitorRunCycleObservers = []
    }

    func prepareForNetworkMonitoring(_ networkMonitor: NetworkMonitor) {
        networkMonitor.watcher = { statusChange in
            DispatchQueue.main.async { [weak self] in
                guard
                    let self = self,
                    let networkMonitor = self.networkMonitor
                else {
                    return
                }
                if statusChange.new.isConnected {
                    self.notifyDelegates { delegate in
                        delegate.magpie(
                            self,
                            networkMonitor: networkMonitor,
                            didConnectVia: statusChange.new.connection,
                            from: statusChange.old.connection
                        )
                    }
                } else {
                    self.notifyDelegates { delegate in
                        delegate.magpie(self, networkMonitor: networkMonitor, didDisconnectFrom: statusChange.old.connection)
                    }
                }
                self.logger.log(networkMonitor)
            }
        }
    }

    func cancelNetworkMonitoring() {
        stopNetworkMonitoring()
        terminateNetworkMonitorRunCycleObservers()
    }
}

extension Magpie: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        let delegateDescriptions = delegators.map { $0.value.description }
        return """
        \(base)
        shared HTTP headers:
        \(sharedHttpHeaders.description)
        ongoing tasks:
        \(taskBin.description)
        delegates:
        [\n\t\(delegateDescriptions.joined(separator: ",\n\t"))\n]
        """
    }

    public var debugDescription: String {
        let delegateDebugDescriptions = delegators.map { $0.value.debugDescription }
        return """
        \(base)
        shared query encoding strategy:
        \(sharedQueryEncodingStrategy.debugDescription)
        shared json body encoding strategy:
        \(sharedJsonBodyEncodingStrategy.debugDescription)
        shared HTTP headers:
        \(sharedHttpHeaders.description)
        shared model decoding strategy:
        \(sharedModelDecodingStrategy.description)
        shared error model decoding strategy:
        \(sharedErrorModelDecodingStrategy.description)
        ongoing tasks:
        \(taskBin.description)
        delegates:
        [\n\t\(delegateDebugDescriptions.joined(separator: ",\n\t"))\n]
        """
    }
}
