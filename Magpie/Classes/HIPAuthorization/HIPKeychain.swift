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

    public func getString(for key: HIPKeychainKeyConvertible) -> String? {
        return _keychain.string(forKey: key.keychainEncoded())
    }

    public func set(_ string: String, for key: HIPKeychainKeyConvertible) {
        _keychain.set(string: string, forKey: key.keychainEncoded())
    }

    public func getData(for key: HIPKeychainKeyConvertible) -> Data? {
        return _keychain.object(forKey: key.keychainEncoded())
    }

    public func set(_ data: Data, for key: HIPKeychainKeyConvertible) {
        _keychain.set(object: data, forKey: key.keychainEncoded())
    }

    public func getModel<T: Model>(for key: HIPKeychainKeyConvertible) -> T? {
        if let data = getData(for: key) {
            return try? T.decoded(data)
        }
        return nil
    }

    public func set<T>(_ model: T, for key: HIPKeychainKeyConvertible) where T : Model {
        if let data = try? model.encoded() {
            set(data, for: key)
        }
    }

    public func remove(for key: HIPKeychainKeyConvertible) {
        _keychain.removeObject(forKey: key.keychainEncoded())
    }

    public func removeAll() {
        _keychain.removeAllObjects()
    }
}

public protocol HIPKeychainConvertible {
    init(identifier: String)

    func getString(for key: HIPKeychainKeyConvertible) -> String?
    func set(_ string: String, for key: HIPKeychainKeyConvertible)
    func getData(for key: HIPKeychainKeyConvertible) -> Data?
    func set(_ data: Data, for key: HIPKeychainKeyConvertible)
    func getModel<T: Model>(for key: HIPKeychainKeyConvertible) -> T?
    func set<T: Model>(_ model: T, for key: HIPKeychainKeyConvertible)
    func remove(for key: HIPKeychainKeyConvertible)
    func removeAll()
}

public protocol HIPKeychainKeyConvertible {
    func keychainEncoded() -> String
}

extension HIPKeychainKeyConvertible where Self: RawRepresentable, Self.RawValue == String {
    public func keychainEncoded() -> String {
        return rawValue
    }
}
