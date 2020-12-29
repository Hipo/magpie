//
//  SecureCache.swift
//  Pods
//
//  Created by Karasuluoglu on 9.10.2020.
//

import Foundation

public protocol SecureCache {
    associatedtype Key: SecureCacheKey

    func getString(for key: Key) throws -> String?
    func set(_ string: String, for key: Key) throws
    func getData(for key: Key) throws -> Data?
    func set(_ data: Data, for key: Key) throws
    func getModel<T: Model>(for key: Key) throws -> T?
    func set<T: Model>(_ model: T, for key: Key) throws
    func remove(for key: Key) throws
    func removeAll() throws
}

extension SecureCache {
    public func removeAll<T: Sequence>(_ keys: T) throws where T.Element == Key {
        try keys.forEach(remove)
    }
}

public protocol SecureCacheKey {
    func secureCacheEncoded() -> String
}

extension SecureCacheKey where Self: RawRepresentable, Self.RawValue == String {
    public func secureCacheEncoded() -> String {
        return rawValue
    }
}

extension SecureCacheKey where Self: RawRepresentable, Self.RawValue == Int {
    public func secureCacheEncoded() -> String {
        return String(rawValue)
    }
}

extension String: SecureCacheKey {
    public func secureCacheEncoded() -> String {
        return self
    }
}
