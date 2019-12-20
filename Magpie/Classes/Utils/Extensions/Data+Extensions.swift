//
//  Data+Extensions.swift
//  Magpie
//
//  Created by Karasuluoglu on 17.12.2019.
//

import Foundation

extension Data {
    public var utf8Description: String {
        if count > 0 {
            return String(data: self, encoding: .utf8) ?? "<unavailable>"
        }
        return "<empty>"
    }
}

extension Optional where Wrapped == Data {
    public var absoluteUtf8Description: String {
        return self?.utf8Description ?? "<nil>"
    }
}

extension Data: Body {
    public func encoded() throws -> Data {
        return self
    }
}
