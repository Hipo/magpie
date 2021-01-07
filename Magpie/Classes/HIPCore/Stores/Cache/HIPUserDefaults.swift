//
//  HIPCache.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation

open class HIPUserDefaults<Key: CacheKey>: Cache {
    public let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    public func getObject<T>(for key: Key) -> T? {
        return userDefaults.object(forKey: key.cacheEncoded()) as? T
    }

    public func set<T>(object: T?, for key: Key) {
        guard let object = object else {
            remove(for: key)
            return
        }
        userDefaults.set(object, forKey: key.cacheEncoded())
        userDefaults.synchronize()
    }

    public func getModel<T: Model>(for key: Key) -> T? {
        if let data: Data = getObject(for: key) {
            return try? T.decoded(data)
        }
        return nil
    }

    public func set<T: Model>(model: T?, for key: Key) {
        guard
            let model = model,
            let data = try? model.encoded()
        else {
            remove(for: key)
            return
        }
        set(object: data, for: key)
    }

    public func remove(for key: Key) {
        userDefaults.removeObject(forKey: key.cacheEncoded())
        userDefaults.synchronize()
    }
}
