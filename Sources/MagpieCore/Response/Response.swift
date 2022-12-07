// Copyright © 2018 hipolabs. All rights reserved.

import Foundation
import MacaroonUtils

public class Response {
    public var isSuccess: Bool {
        return error == nil
    }

    public var isFailure: Bool {
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

    public func decoded<SomeResponseModel: ResponseModel, SomeErrorModel: APIModel>() -> Result<SomeResponseModel, SomeErrorModel> {
        func formResult(_ error: APIError, _ data: Data?) -> Result<SomeResponseModel, SomeErrorModel> {
            if let data = data {
                return .failure(error, try? SomeErrorModel.decoded(data))
            }
            return .failure(error)
        }

        if let error = error {
            return formResult(error, rawData)
        }
        do {
            return .success(try SomeResponseModel.decoded(rawData ?? Data("{}".utf8)))
        } catch let err {
            error = ResponseSerializationError(responseData: rawData, reason: .jsonSerializationFailed(underlyingError: err))
            return formResult(error!, rawData)
        }
    }
}

extension Response {
    public typealias ModelResult<SomeResponseModel: ResponseModel> = Result<SomeResponseModel, NoAPIModel>
    public typealias ErrorModelResult<SomeErrorModel: APIModel> = Result<NoResponseModel, SomeErrorModel>

    public typealias DownloadResult<SomeDownloadModel: DownloadModel, SomeErrorModel: APIModel> = Result<SomeDownloadModel, SomeErrorModel>
    public typealias DownloadModelResult<SomeDownloadModel: DownloadModel> = DownloadResult<SomeDownloadModel, NoAPIModel>

    public enum RawResult {
        case success(Data?)
        case failure(APIError)
    }

    public enum Result<SomeResponseModel: ResponseModel, SomeErrorModel: APIModel> {
        case success(SomeResponseModel)
        case failure(APIError, SomeErrorModel? = nil)
    }
}

extension Response: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        let result: RawResult = decoded()
        let aDescription = "\(request.debugDescription)\n\(result.debugDescription)"

        switch result {
        case .success:
            return aDescription
        case .failure:
            return "\(aDescription)\n\(rawData?.utf8Description ?? "")"
        }
    }
}

extension Response.RawResult {
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    public var isFailure: Bool {
        switch self {
        case .success:
            return false
        case .failure:
            return true
        }
    }
}

extension Response.RawResult: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        switch self {
        case .success(let data):
            return "[SUCCESS]\n\(data?.utf8Description ?? "")"
        case .failure(let error):
            return "[FAILED]\n\(error.localizedDescription)"
        }
    }
}

extension Response.Result {
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    public var isFailure: Bool {
        switch self {
        case .success:
            return false
        case .failure:
            return true
        }
    }
}

extension Response.Result: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        switch self {
        case .success(let model):
            return "[SUCCESS]\n\(model.debugDescription)"
        case .failure(let error, let errorModel):
            return """
            [FAILED]
            \(error.localizedDescription)
            \(errorModel?.debugDescription ?? "<nil>")
            """
        }
    }
}
