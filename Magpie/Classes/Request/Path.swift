//
//  Path.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 21.10.2018.
//

import Foundation

public struct Path {
    let origin: String
    
    public init(_ origin: String) {
        self.origin = origin
    }
}

extension Path {
    public func decoded() -> String {
        return origin
    }
}

extension Path {
    public func contains(_ otherPath: Path) -> Bool {
        let decodedPath = decoded()
        let otherDecodedPath = otherPath.decoded()
        return decodedPath.contains(otherDecodedPath)
    }

    public func contains(_ string: String) -> Bool {
        let decodedPath = decoded()
        return decodedPath.contains(string)
    }
}

extension Path: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(decoded())
    }
    
    public static func == (lhs: Path, rhs: Path) -> Bool {
        let lDecodedPath = lhs.decoded()
        let rDecodedPath = rhs.decoded()
        return lDecodedPath == rDecodedPath
    }
}

extension Path: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self = Path(value)
    }
}

extension Path: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return decoded()
    }
}
