//
//  Path.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 21.10.2018.
//

import Foundation

public struct Path {
    let value: String
    var queryParams: Params?
    
    public init(_ path: String) {
        self.value = path
    }
    
    public mutating func with(query queryParams: Params?) {
        self.queryParams = queryParams
    }
}

extension Path {
    func toString() throws -> String {
        guard let params = queryParams else {
            return value
        }
        
        let query = try params.asQuery()?.encoded() ?? ""
        return value + query
    }
}

extension Path {
    func contains(_ path: Path) -> Bool {
        do {
            let string = try toString()
            let otherString = try path.toString()

            return string.contains(otherString)
        } catch {
            return false
        }
    }
}

extension Path: Hashable {
    public var hashValue: Int {
        guard let string = try? toString() else {
            return value.hashValue
        }
        return string.hashValue
    }
    
    public static func == (
        lhs: Path,
        rhs: Path
    ) -> Bool {
        do {
            let lString = try lhs.toString()
            let rString = try rhs.toString()
            
            return lString == rString
        } catch {
            return false
        }
    }
}

extension Path: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self = Path(value)
    }
}
