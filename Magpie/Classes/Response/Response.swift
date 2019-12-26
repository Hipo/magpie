//
//  Response.swift
//  Pods
//
//  Created by Eray on 19.09.2018.
//

import Foundation

public class Response {
    public var isSucceed: Bool {
        return error == nil
    }

    public var isFailed: Bool {
        return error != nil
    }

    public let request: Request
    public let headers: Headers
    public let rawData: Data?

    public var error: APIError?

    public init(
        request: Request,
        rawHeaders: [AnyHashable: Any]? = nil,
        rawData: Data? = nil,
        error: APIError? = nil
    ) {
        self.request = request
        self.headers = rawHeaders.map { Headers($0) } ?? []
        self.rawData = rawData
        self.error = error
    }
}

extension Response {
    public func decoded() -> RawResult {
        if let error = error {
            return .failure(error)
        }
        return .success(rawData)
    }

    public func decoded<SomeModel: Model, SomeErrorModel: Model>() -> Result<SomeModel, SomeErrorModel> {
        if let error = error {
            if let rawData = rawData {
                return .failure(error, try? SomeErrorModel.decoded(rawData))
            }
            return .failure(error)
        }
        guard let rawData = rawData else {
            error = ResponseSerializationError(responseData: nil, reason: .corruptedData)
            return .failure(error!)
        }
        do {
            return .success(try SomeModel.decoded(rawData))
        } catch let err {
            error = ResponseSerializationError(responseData: rawData, reason: .jsonSerializationFailed(underlyingError: err))
            return .failure(error!, try? SomeErrorModel.decoded(rawData))
        }
    }
}

extension Response {
    public typealias ModelResult<SomeModel: Model> = Result<SomeModel, NoModel>
    public typealias ErrorModelResult<SomeErrorModel: Model> = Result<NoModel, SomeErrorModel>

    public enum RawResult {
        case success(Data?)
        case failure(APIError)
    }

    public enum Result<SomeModel: Model, SomeErrorModel: Model> {
        case success(SomeModel)
        case failure(APIError, SomeErrorModel? = nil)
    }
}

extension Response: Printable {
    public var description: String {
        let result: RawResult = decoded()
        let aDescription = "\(request.description)\n\(result.description)"

        switch result {
        case .success:
            return aDescription
        case .failure:
            return "\(aDescription)\n\(rawData.absoluteUtf8Description)"
        }
    }
}

extension Response.RawResult: Printable {
    /// <mark> CustomStringConvertible
    public var description: String {
        switch self {
        case .success(let data):
            return "[SUCCESS]\n\(data.absoluteUtf8Description)"
        case .failure(let error):
            return "[FAILED]\n\(error.localizedDescription)"
        }
    }
}

extension Response.Result: Printable {
    /// <mark> CustomStringConvertible
    public var description: String {
        switch self {
        case .success(let model):
            return "[SUCCESS]\n\(model.description)"
        case .failure(let error, let errorModel):
            return """
            [FAILED]
            \(error.localizedDescription)
            \(errorModel?.description ?? "<nil>")
            """
        }
    }
}
