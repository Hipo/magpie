//
//  Endpoint.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 2.04.2019.
//

import Foundation

open class Endpoint {
    var context: EndpointContext
    var task: TaskConvertible?

    /// <note>
    /// This variable is added considering the validation capability of Alamofire. Normally, you won't need it, but it may be useful
    /// for some cases.
    /// If you use your own Networking class, it can be used to determine if the response is success or fail before processing the result.
    private(set) var validatesResponseFirstWhenReceived = true
    private(set) var resultHandler: ResultHandler?
    private(set) var ignoresResultWhenCancelled = true
    private(set) var ignoresResultWhenDelegatesNotified = true

    private(set) var notifiesDelegatesWhenFailedFromUnauthorizedRequest = true
    private(set) var notifiesDelegatesWhenFailedFromUnavailableNetwork = false
    private(set) var notifiesDelegatesWhenFailedFromUnresponsiveServer = false

    let request: Request

    public required init(path: Path) {
        context = .data
        request = Request(path: path)
    }
}

extension Endpoint {
    func setIfNeeded(_ base: String) {
        if request.base.isEmpty {
            request.base = base
        }
    }

    func setIfNeeded(_ encodingStrategy: QueryEncodingStrategy) {
        request.queryEncoder?.setIfNeeded(encodingStrategy)
    }

    func setIfNeeded(_ encodingStrategy: JSONBodyEncodingStrategy) {
        request.httpBodyEncoder?.setIfNeeded(encodingStrategy)
    }

    /// <warning>
    /// The headers which has already been set on the endpoint may override these ones.
    func setIfNeeded(_ additionalHttpHeaders: Headers) {
        let httpHeaders = request.httpHeaders
        request.httpHeaders = additionalHttpHeaders + httpHeaders
    }

    func set(_ task: TaskConvertible?) {
        self.task = task
    }
}

extension Endpoint {
    public func validateResponseFirstWhenReceived(_ shouldValidate: Bool) -> Self {
        validatesResponseFirstWhenReceived = shouldValidate
        return self
    }
}

extension Endpoint {
    public func resultHandler<AnyModel: Model, ErrorModel: Model>(
        _ resultHandler: @escaping CompleteResultHandler<AnyModel, ErrorModel>,
        using modelDecodingStrategy: ModelDecodingStrategy? = nil,
        forErrorModel errorModelDecodingStrategy: ModelDecodingStrategy? = nil
    ) -> Self {
        self.resultHandler = CompleteResultTransformer(resultHandler)
        self.resultHandler?.modelDecodingStrategy = modelDecodingStrategy
        self.resultHandler?.errorModelDecodingStrategy = errorModelDecodingStrategy
        return self
    }

    public func resultHandler<AnyModel: Model>(
        _ resultHandler: @escaping DefaultResultHandler<AnyModel>,
        using modelDecodingStrategy: ModelDecodingStrategy? = nil
    ) -> Self {
        self.resultHandler = DefaultResultTransformer(resultHandler)
        self.resultHandler?.modelDecodingStrategy = modelDecodingStrategy
        return self
    }

    public func resultHandler<AnyModel: Model>(
        _ resultHandler: @escaping ModelResultHandler<AnyModel>,
        using modelDecodingStrategy: ModelDecodingStrategy? = nil
    ) -> Self {
        self.resultHandler = ModelResultTransformer(resultHandler)
        self.resultHandler?.modelDecodingStrategy = modelDecodingStrategy
        return self
    }

    public func resultHandler(_ resultHandler: @escaping RawResultHandler) -> Self {
        self.resultHandler = RawResultTransformer(resultHandler)
        return self
    }

    public func resultHandler(_ resultHandler: @escaping ErrorResultHandler) -> Self {
        self.resultHandler = ErrorResultTransformer(resultHandler)
        return self
    }

    func setModelDecodingStrategyIfNeeded(_ decodingStrategy: ModelDecodingStrategy) {
        if resultHandler?.modelDecodingStrategy == nil {
            resultHandler?.modelDecodingStrategy = decodingStrategy
        }
    }

    func setErrorModelDecodingStrategyIfNeeded(_ decodingStrategy: ModelDecodingStrategy) {
        if resultHandler?.errorModelDecodingStrategy == nil {
            resultHandler?.errorModelDecodingStrategy = decodingStrategy
        }
    }

    func advance(_ response: Response) {
        resultHandler?.awake(with: response)
    }
}

extension Endpoint {
    /// <note>
    /// The result handler won't be called by default when the request is cancelled.
    public func ignoreResultWhenCancelled(_ shouldIgnore: Bool) -> Self {
        ignoresResultWhenCancelled = shouldIgnore
        return self
    }

    /// <note>
    /// The result handler won't be called by default when the delegates are notified for a case.
    public func ignoreResultWhenDelegatesNotified(_ shouldNotify: Bool) -> Self {
        ignoresResultWhenDelegatesNotified = shouldNotify
        return self
    }

    /// <note>
    /// The delegates will be notified by default when an authorized request received.
    public func notifyDelegatesWhenFailedFromUnauthorizedRequest(_ shouldNotify: Bool) -> Self {
        notifiesDelegatesWhenFailedFromUnauthorizedRequest = shouldNotify
        return self
    }

    /// <note>
    /// The delegates won't be notified by default from an unavailable network connection. It should be set true if it is intended to
    /// track the error from a common place.
    public func notifyDelegatesWhenFailedFromUnavailableNetwork(_ shouldNotify: Bool) -> Self {
        notifiesDelegatesWhenFailedFromUnavailableNetwork = shouldNotify
        return self
    }

    /// <note>
    /// The delegates won't be notified by default from a server error. It should be set true if it is intended to
    /// track the error from a common place.
    public func notifyDelegatesWhenFailedFromUnresponsiveServer(_ shouldNotify: Bool) -> Self {
        notifiesDelegatesWhenFailedFromUnresponsiveServer = shouldNotify
        return self
    }
}

extension Endpoint {
    public typealias CompleteResultHandler<AnyModel: Model, ErrorModel: Model> = (Response.Result<AnyModel, ErrorModel>) -> Void
    public typealias DefaultResultHandler<AnyModel: Model> = (Response.ModelResult<AnyModel>) -> Void
    public typealias ModelResultHandler<AnyModel: Model> = (AnyModel?) -> Void
    public typealias RawResultHandler = (Response.RawResult) -> Void
    public typealias ErrorResultHandler = (Error?) -> Void

    private struct CompleteResultTransformer<AnyModel: Model, ErrorModel: Model>: ResultHandler {
        typealias Handler = CompleteResultHandler<AnyModel, ErrorModel>

        var modelDecodingStrategy: ModelDecodingStrategy?
        var errorModelDecodingStrategy: ModelDecodingStrategy?

        let underlyingHandler: Handler

        init(_ underlyingHandler: @escaping Handler) {
            self.underlyingHandler = underlyingHandler
        }

        func awake(with response: Response) {
            underlyingHandler(response.decoded(using: modelDecodingStrategy, forErrorModel: errorModelDecodingStrategy))
        }
    }

    private struct DefaultResultTransformer<AnyModel: Model>: ResultHandler {
        typealias Handler = DefaultResultHandler<AnyModel>

        var modelDecodingStrategy: ModelDecodingStrategy?
        var errorModelDecodingStrategy: ModelDecodingStrategy?

        let underlyingHandler: Handler

        init(_ underlyingHandler: @escaping Handler) {
            self.underlyingHandler = underlyingHandler
        }

        func awake(with response: Response) {
            underlyingHandler(response.decoded(using: modelDecodingStrategy))
        }
    }

    private struct ModelResultTransformer<AnyModel: Model>: ResultHandler {
        typealias Handler = ModelResultHandler<AnyModel>

        var modelDecodingStrategy: ModelDecodingStrategy?
        var errorModelDecodingStrategy: ModelDecodingStrategy?

        let underlyingHandler: Handler

        init(_ underlyingHandler: @escaping Handler) {
            self.underlyingHandler = underlyingHandler
        }

        func awake(with response: Response) {
            let result: Response.ModelResult<AnyModel> = response.decoded(using: modelDecodingStrategy)

            switch result {
            case .success(let model):
                underlyingHandler(model)
            case .failure:
                underlyingHandler(nil)
            }
        }
    }

    private struct RawResultTransformer: ResultHandler {
        var modelDecodingStrategy: ModelDecodingStrategy?
        var errorModelDecodingStrategy: ModelDecodingStrategy?

        let underlyingHandler: RawResultHandler

        init(_ underlyingHandler: @escaping RawResultHandler) {
            self.underlyingHandler = underlyingHandler
        }

        func awake(with response: Response) {
            underlyingHandler(response.decoded())
        }
    }

    private struct ErrorResultTransformer: ResultHandler {
        var modelDecodingStrategy: ModelDecodingStrategy?
        var errorModelDecodingStrategy: ModelDecodingStrategy?

        let underlyingHandler: ErrorResultHandler

        init(_ underlyingHandler: @escaping ErrorResultHandler) {
            self.underlyingHandler = underlyingHandler
        }

        func awake(with response: Response) {
            switch response.decoded() {
            case .success:
                underlyingHandler(nil)
            case .failure(let error):
                underlyingHandler(error)
            }
        }
    }
}

extension Endpoint: EndpointBuildable {
    public func context(_ context: EndpointContext) -> Self {
        self.context = context
        return self
    }

    public func base(_ base: String) -> Self {
        request.base = base
        return self
    }

    public func httpMethod(_ httpMethod: Method) -> Self {
        request.httpMethod = httpMethod
        return self
    }

    public func query<T: Query>(_ query: T, using encodingStrategy: QueryEncodingStrategy? = nil) -> Self {
        request.queryEncoder = QueryEncoder(query: query, encodingStrategy: encodingStrategy)
        return self
    }

    public func httpBody(_ body: Body) -> Self {
        request.httpBodyEncoder = BodyEncoder(body: body)
        return self
    }

    public func httpBody<T: JSONBody>(_ jsonBody: T, using encodingStrategy: JSONBodyEncodingStrategy? = nil) -> Self {
        request.httpBodyEncoder = JSONBodyEncoder(jsonBody: jsonBody, encodingStrategy: encodingStrategy)
        return self
    }

    public func httpHeaders(_ httpHeaders: Headers) -> Self {
        request.httpHeaders = httpHeaders
        return self
    }

    public func timeout(_ timeout: TimeInterval) -> Self {
        request.timeout = timeout
        return self
    }

    public func cachePolicy(_ cachePolicy: NSURLRequest.CachePolicy) -> Self {
        request.cachePolicy = cachePolicy
        return self
    }

    @discardableResult
    public func build(_ magpie: Magpie) -> EndpointOperatable {
        return EndpointOperator(endpoint: self, magpie: magpie)
    }

    @discardableResult
    public func buildAndSend(_ magpie: Magpie) -> EndpointOperatable {
        let endpointOperator = build(magpie)
        endpointOperator.send()
        return endpointOperator
    }
}

extension Endpoint: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "\(request.description)"
    }

    public var debugDescription: String {
        return """
        request(\(context.description)):
        \(request.debugDescription)
        task:
        \(task?.debugDescription ?? "<nil>")
        options:
        validates response first when received \(validatesResponseFirstWhenReceived)
        ignores result when cancelled \(ignoresResultWhenCancelled)
        ignores result when delegates notified \(ignoresResultWhenDelegatesNotified)
        notifies delegates when failed from unauthorized request \(notifiesDelegatesWhenFailedFromUnauthorizedRequest)
        notifies delegates when failed from unavailable network \(notifiesDelegatesWhenFailedFromUnavailableNetwork)
        notifies delegates when failed from unresponsive server \(notifiesDelegatesWhenFailedFromUnresponsiveServer)
        """
    }
}

extension Endpoint: LogPrintable {
    var log: String {
        return request.debugDescription
    }
}
