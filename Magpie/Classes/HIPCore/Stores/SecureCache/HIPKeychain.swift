//
//  HIPKeychain.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation
import Valet

open class HIPKeychain<Key: SecureCacheKey>: SecureCache {
    private let _keychain: Valet

    public init(
        identifier: String = "\(HIPApplication().packageName).keychain",
        accessibility: Accessibility = .whenUnlocked
    ) {
        _keychain = Valet.valet(with: Identifier(nonEmpty: identifier)!, accessibility: accessibility)
    }

    public subscript(string key: Key) -> String? {
        get { try? _keychain.string(forKey: key.secureCacheEncoded()) }
        set {
            guard let string = newValue else {
                remove(for: key)
                return
            }
            try? _keychain.setString(string, forKey: key.secureCacheEncoded())
        }
    }

    public subscript(data key: Key) -> Data? {
        get { try? _keychain.object(forKey: key.secureCacheEncoded()) }
        set {
            guard let data = newValue else {
                remove(for: key)
                return
            }
            try? _keychain.setObject(data, forKey: key.secureCacheEncoded())
        }
    }

    public subscript<T: Model>(model key: Key) -> T? {
        get {
            guard let data = self[data: key] else {
                return nil
            }
            return try? T.decoded(data)
        }
        set {
            guard let data = try? newValue?.encoded() else {
                remove(for: key)
                return
            }
            self[data: key] = data
        }
    }

    public func remove(for key: Key) {
        try? _keychain.removeObject(forKey: key.secureCacheEncoded())
    }
}
