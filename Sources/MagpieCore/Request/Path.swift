//
//  Path.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 26.03.2021.
//

import Foundation
import MacaroonUtils

public struct Path:
    ExpressibleByStringLiteral,
    DebugPrintable {
    public let expr: String
    public let args: [CVarArg]

    private let path: String

    public init(
        _ expr: String,
        args: CVarArg...
    ) {
        self.init(
            expr,
            args: args
        )
    }

    public init(
        _ expr: String,
        args: [CVarArg]
    ) {
        self.expr = expr
        self.args = args
        self.path = args.isEmpty ? expr : String(format: expr, arguments: args)
    }

    public init(
        stringLiteral value: String
    ) {
        self.init(
            value
        )
    }

    public func encoded() -> String {
        return path
    }
}

extension Path {
    /// <mark>
    /// CustomDebugStringConvertible
    public var debugDescription: String {
        return encoded()
    }
}
