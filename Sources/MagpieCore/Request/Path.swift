//
//  Path.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 26.03.2021.
//

import Foundation
import MacaroonUtils

public struct Path: DebugPrintable {
    private let encodedString: String
    
    public init(
        _ string: String
    ) {
        self.init(
            format: string,
            arguments: []
        )
    }

    public init(
        format: String,
        arguments: CVarArg...
    ) {
        self.init(
            format: format,
            arguments: arguments
        )
    }

    init(
        format: String,
        arguments: [CVarArg]
    ) {
        self.encodedString = String(format: format, arguments: arguments)
    }
}

extension Path {
    public func encoded() -> String {
        return encodedString
    }
}

extension Path {
    /// <mark>
    /// CustomDebugStringConvertible
    public var debugDescription: String {
        return encoded()
    }
}
