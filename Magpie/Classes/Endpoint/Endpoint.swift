//
//  Endpoint.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 2.04.2019.
//

import Foundation

class Endpoint {
    var task: TaskConvertible?
    var responseResolver: ResponseResolver?

    var type: EndpointType = .data

    var isSentOnce = false

    /// <note> This variable is added considering the validation capability of Alamofire. It's not generally needed, but it may be useful for some cases.
    /// If you use your own Networking class, it can be used to determine if the response is succeeded or failed before complete the endpoint.
    var validatesResponseBeforeCompletion = true
    var ignoresResponseOnCancelled = true
    var ignoresResponseWhenListenersNotified = false

    var notifiesListenersOnFailedFromUnauthorizedRequest = true

    var notifiesListenersOnFailedFromUnavailableNetwork: Bool
    var notifiesListenersOnFailedFromDefectiveClient: Bool
    var notifiesListenersOnFailedFromUnresponsiveServer: Bool

    weak var api: API?

    let request: Request

    init(api: API) {
        self.api = api
        self.request = Request(base: api.base)
        self.notifiesListenersOnFailedFromUnavailableNetwork = api.notifiesListenersWhenEndpointsFailedFromUnavailableNetwork
        self.notifiesListenersOnFailedFromDefectiveClient = api.notifiesListenersWhenEndpointsFailedFromDefectiveClient
        self.notifiesListenersOnFailedFromUnresponsiveServer = api.notifiesListenersWhenEndpointsFailedFromUnresponsiveServer
    }

    func set(base: String) {
        request.base = base
    }

    func set(path: String) {
        request.path = path
    }

    func set(method: Method) {
        request.method = method
    }

    func set(query: Query) {
        request.query = query
    }

    func set(body: Body) {
        request.body = body
    }

    func set(headers: Headers) {
        request.headers = headers
    }

    func set(additionalHeaders: Headers) {
        request.headers = request.headers + additionalHeaders
    }

    func set(timeout: TimeInterval) {
        request.timeout = timeout
    }

    func set(cachePolicy: Request.CachePolicy) {
        request.cachePolicy = cachePolicy
    }
}

extension Endpoint {
    func forward(_ response: Response) {
        responseResolver?.resolve(response)
    }
}

extension Endpoint: EndpointOperatable {
    func send() {
        isSentOnce = true
        task = api?.send(self)
    }

    func retry() {
        if isSentOnce {
            task = api?.send(self)
        } else {
            let error = EndpointOperationError(reason: .retryBeforeSent)
            forward(Response(request: request, error: error))
        }
    }

    func cancel() {
        task?.cancelNow()
    }
}

extension Endpoint {
    /// <mark> CustomStringConvertible
    var description: String {
        return "\(request.description)"
    }
    /// <mark> CustomDebugStringConvertible
    var debugDescription: String {
        return """
        request(\(type.description))
        \(request.debugDescription)
        \(task.map { "task with id(\($0.taskIdentifier))" } ?? "no task") attached
        \(validatesResponseBeforeCompletion ? "validate" : "not validate") response before completion
        \(ignoresResponseOnCancelled ? "ignores" : "not ignore") response on cancelled
        \(ignoresResponseWhenListenersNotified ? "ignores" : "not ignore") response when listeners notified
        \(notifiesListenersOnFailedFromUnauthorizedRequest ? "notifies" : "not notify") listeners on failed from unauthorized request
        \(notifiesListenersOnFailedFromUnavailableNetwork ? "notifies" : "not notify") listeners on failed from unavailable network
        \(notifiesListenersOnFailedFromDefectiveClient ? "notifies" : "not notify") listeners on failed from defective client
        \(notifiesListenersOnFailedFromUnresponsiveServer ? "notifies" : "not notify") listeners on failed from unresponsive server
        """
    }
}
