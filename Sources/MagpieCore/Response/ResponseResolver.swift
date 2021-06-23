//
//  ResponseResolver.swift
//  Magpie
//
//  Created by Karasuluoglu on 19.12.2019.
//

import Foundation
import MacaroonUtils

public protocol ResponseResolver {
    func resolve(_ response: Response)
}

struct ResponseResultResolver<SomeResponseModel: ResponseModel, SomeErrorModel: JSONModel>: ResponseResolver {
    typealias CompletionHandler = (Response.Result<SomeResponseModel, SomeErrorModel>, Headers) -> Void

    let completionHandler: CompletionHandler

    init(_ completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
    }

    func resolve(_ response: Response) {
        completionHandler(response.decoded(), response.headers)
    }
}

struct ResponseRawResultResolver: ResponseResolver {
    typealias CompletionHandler = (Response.RawResult, Headers) -> Void

    let completionHandler: CompletionHandler

    init(_ completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
    }

    func resolve(_ response: Response) {
        completionHandler(response.decoded(), response.headers)
    }
}

struct ResponseModelResultResolver<SomeResponseModel: ResponseModel>: ResponseResolver {
    typealias CompletionHandler = (Response.Result<SomeResponseModel, NoJSONModel>, Headers) -> Void

    let completionHandler: CompletionHandler

    init(_ completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
    }

    func resolve(_ response: Response) {
        completionHandler(response.decoded(), response.headers)
    }
}

struct ResponseModelResolver<SomeResponseModel: ResponseModel>: ResponseResolver {
    typealias CompletionHandler = (SomeResponseModel?, Headers) -> Void

    let completionHandler: CompletionHandler

    init(_ completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
    }

    func resolve(_ response: Response) {
        switch response.decoded() as Response.Result<SomeResponseModel, NoJSONModel> {
        case .success(let model):
            completionHandler(model, response.headers)
        case .failure:
            completionHandler(nil, response.headers)
        }
    }
}

struct ResponseErrorResultResolver<SomeErrorModel: JSONModel>: ResponseResolver {
    typealias CompletionHandler = (Response.Result<NoResponseModel, SomeErrorModel>, Headers) -> Void

    let completionHandler: CompletionHandler

    init(_ completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
    }

    func resolve(_ response: Response) {
        completionHandler(response.decoded(), response.headers)
    }
}

struct ResponseErrorResolver: ResponseResolver {
    typealias CompletionHandler = (APIError?, Headers) -> Void

    let completionHandler: CompletionHandler

    init(_ completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
    }

    func resolve(_ response: Response) {
        switch response.decoded() {
        case .success:
            completionHandler(nil, response.headers)
        case .failure(let error):
            completionHandler(error, response.headers)
        }
    }
}
