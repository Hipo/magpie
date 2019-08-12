//
//  Response.swift
//  Pods
//
//  Created by Eray on 19.09.2018.
//

import Foundation

public class Response {
    public var data: Data?
    public var errorContainer: ErrorContainer?

    public var isSucceed: Bool {
        return errorContainer == nil
    }

    public var isFailed: Bool {
        return errorContainer != nil
    }

    public let request: Request
    public let httpHeaders: Headers

    public init(
        request: Request,
        fields: [AnyHashable: Any]? = nil,
        data: Data? = nil,
        errorContainer: ErrorContainer? = nil
    ) {
        self.request = request
        self.httpHeaders = fields.map { Headers($0) } ?? []
        self.data = data
        self.errorContainer = errorContainer
    }
}

extension Response {
    public func decoded() -> RawResult {
        guard let errorContainer = errorContainer else {
            return .success(data)
        }
        return .failure(errorContainer.decoded())
    }

    public func decoded<AnyModel: Model>(using decodingStrategy: ModelDecodingStrategy? = nil) -> ModelResult<AnyModel> {
        guard let errorContainer = errorContainer else {
            guard let data = data else {
                return .failure(.responseSerialization(.emptyOrCorruptedData(nil)))
            }
            do {
                let instance = try AnyModel.decoded(from: data, using: decodingStrategy)
                return .success(instance)
            } catch let error {
                return .failure(.responseSerialization(.jsonSerializationFailed(data, error)))
            }
        }
        return .failure(errorContainer.decoded())
    }

    public func decoded<ErrorModel: Model>(using errorModelDecodingStrategy: ModelDecodingStrategy? = nil) -> ErrorResult<ErrorModel> {
        guard let errorContainer = errorContainer else {
            return .success
        }
        guard
            let data = data,
            let errorInstance = try? ErrorModel.decoded(from: data, using: errorModelDecodingStrategy)
        else {
            return .failure(errorContainer.decoded(), nil)
        }
        return .failure(errorContainer.decoded(), errorInstance)
    }

    public func decoded<AnyModel: Model, ErrorModel: Model>(
        using modelDecodingStrategy: ModelDecodingStrategy? = nil,
        forErrorModel errorModelDecodingStrategy: ModelDecodingStrategy? = nil
    ) -> Result<AnyModel, ErrorModel> {
        guard let errorContainer = errorContainer else {
            guard let data = data else {
                return .failure(.responseSerialization(.emptyOrCorruptedData(nil)), nil)
            }
            do {
                let instance = try AnyModel.decoded(from: data, using: modelDecodingStrategy)
                return .success(instance)
            } catch let error {
                let errorInstance = try? ErrorModel.decoded(from: data, using: errorModelDecodingStrategy)
                return .failure(.responseSerialization(.jsonSerializationFailed(data, error)), errorInstance)
            }
        }
        guard
            let data = data,
            let errorInstance = try? ErrorModel.decoded(from: data, using: errorModelDecodingStrategy)
        else {
            return .failure(errorContainer.decoded(), nil)
        }
        return .failure(errorContainer.decoded(), errorInstance)
    }
}

extension Response {
    public enum RawResult {
        case success(Data?)
        case failure(Error)
    }

    public enum ModelResult<AnyModel: Model> {
        case success(AnyModel)
        case failure(Error)
    }

    public enum ErrorResult<ErrorModel: Model> {
        case success
        case failure(Error, ErrorModel?)
    }

    public enum Result<AnyModel: Model, ErrorModel: Model> {
        case success(AnyModel)
        case failure(Error, ErrorModel?)
    }
}

extension Response: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        let result: RawResult = decoded()

        var finalDescription = """
        request:
        \(request.description)
        result:
        \(result.description)
        """

        if case RawResult.failure = result {
            if let data = data, data.count > 0 {
                finalDescription += "\ndata:\n\(data.toString())"
            }
        }
        return finalDescription
    }
}

extension Response.RawResult: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .success(let data):
            return """
            Success.
            data:
            \(data?.toString() ?? "<nil>")
            """
        case .failure(let error):
            return """
            Failed.
            error:
            \(error.localizedDescription)
            """
        }
    }
}

extension Response.ModelResult: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .success(let instance):
            return """
            Success.
            data:
            \(instance.description)
            """
        case .failure(let error):
            return """
            Failed.
            error:
            \(error.localizedDescription)
            """
        }
    }
}

extension Response.Result: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .success(let instance):
            return """
            Success.
            data:
            \(instance.description)
            """
        case .failure(let error, let errorInstance):
            return """
            Failed.
            error:
            \(error.localizedDescription)
            data:
            \(errorInstance?.description ?? "<nil>")
            """
        }
    }
}
