//
//  Printable.swift
//  Magpie
//
//  Created by Karasuluoglu on 17.12.2019.
//

import Foundation

public typealias Printable = CustomStringConvertible & CustomDebugStringConvertible

extension CustomStringConvertible where Self: RawRepresentable, Self.RawValue == String {
    public var description: String {
        return rawValue
    }
}

extension CustomDebugStringConvertible where Self: CustomStringConvertible {
    public var debugDescription: String {
        return description
    }
}
