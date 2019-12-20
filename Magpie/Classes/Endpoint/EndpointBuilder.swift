//
//  EndpointBuilder.swift
//  Magpie
//
//  Created by Karasuluoglu on 18.12.2019.
//

import Foundation

open class EndpointBuilder {
    let endpoint: Endpoint

    public init(api: API) {
        self.endpoint = Endpoint(api: api)
    }

    public func type(_ someType: EndpointType) {
        endpoint.type = someType
    }

    public func base(_ someBase: String) {
        endpoint.set(base: someBase)
    }

    public func path(_ somePath: String) {
        endpoint.set(path: somePath)
    }

    public func method(_ someMethod: Method) {
        endpoint.set(method: someMethod)
    }

    public func query(_ someQuery: Query) {
        endpoint.set(query: someQuery)
    }

    public func body(_ someBody: Body) {
        endpoint.set(body: someBody)
    }

    public func headers(_ someHeaders: Headers) {
        endpoint.set(headers: someHeaders)
    }

    public func timeout(_ someTimeout: TimeInterval) {
        endpoint.set(timeout: someTimeout)
    }

    public func cachePolicy(_ someCachePolicy: Request.CachePolicy) {
        endpoint.set(cachePolicy: someCachePolicy)
    }

    public func validateResponseBeforeEndpointCompleted(_ shouldValidate: Bool) {
        endpoint.validatesResponseBeforeCompletion = shouldValidate
    }

    public func ignoreResponseWhenEndpointCancelled(_ shouldIgnore: Bool) {
        endpoint.ignoresResponseOnCancelled = shouldIgnore
    }

    public func ignoreResponseWhenEndpointListenersNotified(_ shouldIgnore: Bool) {
        endpoint.ignoresResponseWhenListenersNotified = shouldIgnore
    }

    public func notifyListenersWhenEndpointFailedFromUnauthorizedRequest(_ shouldNotify: Bool) {
        endpoint.notifiesListenersOnFailedFromUnauthorizedRequest = shouldNotify
    }

    public func notifyListenersWhenEndpointFailedFromUnavailableNetwork(_ shouldNotify: Bool) {
        endpoint.notifiesListenersOnFailedFromUnavailableNetwork = shouldNotify
    }

    public func notifyListenersWhenEndpointFailedFromDefectiveClient(_ shouldNotify: Bool) {
        endpoint.notifiesListenersOnFailedFromDefectiveClient = shouldNotify
    }

    public func notifyListenersWhenEndpointFailedFromUnresponsiveServer(_ shouldNotify: Bool) {
        endpoint.notifiesListenersOnFailedFromUnresponsiveServer = shouldNotify
    }

    public func completionHandler<SomeModel: Model, SomeErrorModel: Model>(_ someCompletionHandler: @escaping (Response.Result<SomeModel, SomeErrorModel>, Headers) -> Void) {
        endpoint.responseResolver = ResponseResultResolver(someCompletionHandler)
    }

    public func completionHandler(_ someCompletionHandler: @escaping (Response.RawResult, Headers) -> Void) {
        endpoint.responseResolver = ResponseRawResultResolver(someCompletionHandler)
    }

    public func completionHandler<SomeModel: Model>(_ someCompletionHandler: @escaping (Response.Result<SomeModel, NoModel>, Headers) -> Void) {
        endpoint.responseResolver = ResponseModelResultResolver(someCompletionHandler)
    }

    public func completionHandler<SomeModel: Model>(_ someCompletionHandler: @escaping (SomeModel?, Headers) -> Void) {
        endpoint.responseResolver = ResponseModelResolver(someCompletionHandler)
    }

    public func completionHandler<SomeErrorModel: Model>(_ someCompletionHandler: @escaping (Response.Result<NoModel, SomeErrorModel>, Headers) -> Void) {
        endpoint.responseResolver = ResponseErrorResultResolver(someCompletionHandler)
    }

    public func completionHandler(_ someCompletionHandler: @escaping (APIError?, Headers) -> Void) {
        endpoint.responseResolver = ResponseErrorResolver(someCompletionHandler)
    }

    public func responseResolver(_ someResponseResolver: ResponseResolver) {
        endpoint.responseResolver = someResponseResolver
    }

    public func build() -> EndpointOperatable {
        return endpoint
    }
}

