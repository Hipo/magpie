//
//  HIPKeychain.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation
import Valet

public class HIPKeychain<Key: SecureCacheKey>: SecureCache {
    private let _keychain: Valet

    public init(
        identifier: String = "\(HIPApplication().packageName).keychain",
        accessibility: Accessibility = .whenUnlocked
    ) {
        _keychain = Valet.valet(with: Identifier(nonEmpty: identifier)!, accessibility: accessibility)
    }

    public func getString(for key: Key) throws -> String? {
        return try _keychain.string(forKey: key.secureCacheEncoded())
    }

    public func set(_ string: String, for key: Key) throws {
        try _keychain.setString(string, forKey: key.secureCacheEncoded())
    }

    public func getData(for key: Key) throws -> Data? {
        return try _keychain.object(forKey: key.secureCacheEncoded())
    }

    public func set(_ data: Data, for key: Key) throws {
        try _keychain.setObject(data, forKey: key.secureCacheEncoded())
    }

    public func getModel<T: Model>(for key: Key) throws -> T? {
        if let data = try getData(for: key) {
            return try T.decoded(data)
        }
        return nil
    }

    public func set<T: Model>(_ model: T, for key: Key) throws {
        let data = try model.encoded()
        try set(data, for: key)
    }

    public func remove(for key: Key) throws {
        try _keychain.removeObject(forKey: key.secureCacheEncoded())
    }

    public func removeAll() throws {
        try _keychain.removeAllObjects()
    }
}
