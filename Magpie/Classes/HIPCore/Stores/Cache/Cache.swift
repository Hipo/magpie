//
//  TempCache.swift
//  Pods
//
//  Created by Karasuluoglu on 9.10.2020.
//

import Foundation

public protocol Cache {
    associatedtype Key: CacheKey

    func getObject<T>(for key: Key) -> T?
    func set<T>(object: T?, for key: Key)
    func getModel<T: Model>(for key: Key) -> T?
    func set<T: Model>(model: T?, for key: Key)
    func remove(for key: Key)
}

extension Cache {
    public func removeAll<T: Sequence>(for keys: T) where T.Element == Key {
        keys.forEach(remove)
    }
}

public protocol CacheKey {
    func cacheEncoded() -> String
}

extension CacheKey where Self: RawRepresentable, Self.RawValue == String {
    public func cacheEncoded() -> String {
        return rawValue
    }
}

extension CacheKey where Self: RawRepresentable, Self.RawValue == Int {
    public func cacheEncoded() -> String {
        return String(rawValue)
    }
}

extension String: CacheKey {
    public func cacheEncoded() -> String {
        return self
    }
}
