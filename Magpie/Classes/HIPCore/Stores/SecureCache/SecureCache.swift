//
//  SecureCache.swift
//  Pods
//
//  Created by Karasuluoglu on 9.10.2020.
//

import Foundation

public protocol SecureCache: AnyObject {
    associatedtype Key: SecureCacheKey

    subscript(string key: Key) -> String? { get set }
    subscript(data key: Key) -> Data? { get set }
    subscript<T: Model>(model key: Key) -> T? { get set }

    func remove(for key: Key)
}

extension SecureCache {
    public func removeAll<T: Sequence>(_ keys: T) where T.Element == Key {
        keys.forEach(remove)
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
