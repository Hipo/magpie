//
//  ErrorContainer.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 26.03.2019.
//

import Foundation

public struct ErrorContainer {
    public enum Origin {
        case magpie(Error)
        case foundation(FoundationError)
        case url(URLError)
        case unknown(Any?)
    }

    let origin: Origin

    public init(origin: Origin) {
        self.origin = origin
    }
}

extension ErrorContainer {
    public func decoded() -> Error {
        switch origin {
        case .magpie(let originalError):
            return originalError
        case .foundation(let originalError):
            return .unknown(originalError)
        case .url(let originalError):
            return Error.populate(from: originalError)
        case .unknown(let originalError):
            return .custom(originalError)
        }
    }
}

extension ErrorContainer: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return decoded().localizedDescription
    }
}
