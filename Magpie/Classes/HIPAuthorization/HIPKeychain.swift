//
//  HIPKeychain.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation
import Valet

public class HIPKeychain: HIPKeychainConvertible {
    private let _keychain: Valet

    public required init(identifier: String) {
        _keychain = Valet.valet(with: Identifier(nonEmpty: identifier)!, accessibility: .whenUnlocked)
    }

    public func getString(for key: HIPKeychainKeyConvertible) throws -> String? {
        return try _keychain.string(forKey: key.keychainEncoded())
    }

    public func set(_ string: String, for key: HIPKeychainKeyConvertible) throws {
        try _keychain.setString(string, forKey: key.keychainEncoded())
    }

    public func getData(for key: HIPKeychainKeyConvertible) throws -> Data? {
        return try _keychain.object(forKey: key.keychainEncoded())
    }

    public func set(_ data: Data, for key: HIPKeychainKeyConvertible) throws {
        try _keychain.setObject(data, forKey: key.keychainEncoded())
    }

    public func getModel<T: Model>(for key: HIPKeychainKeyConvertible) throws -> T? {
        if let data = try getData(for: key) {
            return try T.decoded(data)
        }
        return nil
    }

    public func set<T: Model>(_ model: T, for key: HIPKeychainKeyConvertible) throws {
        let data = try model.encoded()
        try set(data, for: key)
    }

    public func remove(for key: HIPKeychainKeyConvertible) throws {
        try _keychain.removeObject(forKey: key.keychainEncoded())
    }

    public func removeAll() throws {
        try _keychain.removeAllObjects()
    }
}

public protocol HIPKeychainConvertible {
    init(identifier: String)

    func getString(for key: HIPKeychainKeyConvertible) throws -> String?
    func set(_ string: String, for key: HIPKeychainKeyConvertible) throws
    func getData(for key: HIPKeychainKeyConvertible) throws -> Data?
    func set(_ data: Data, for key: HIPKeychainKeyConvertible) throws
    func getModel<T: Model>(for key: HIPKeychainKeyConvertible) throws -> T?
    func set<T: Model>(_ model: T, for key: HIPKeychainKeyConvertible) throws
    func remove(for key: HIPKeychainKeyConvertible) throws
    func removeAll() throws
}

public protocol HIPKeychainKeyConvertible {
    func keychainEncoded() -> String
}

extension HIPKeychainKeyConvertible where Self: RawRepresentable, Self.RawValue == String {
    public func keychainEncoded() -> String {
        return rawValue
    }
}
