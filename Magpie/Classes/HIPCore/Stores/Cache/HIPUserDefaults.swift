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

    public subscript<T>(object key: Key) -> T? {
        get { userDefaults.object(forKey: key.cacheEncoded()) as? T }
        set {
            guard let object = newValue else {
                remove(for: key)
                return
            }
            userDefaults.set(object, forKey: key.cacheEncoded())
            userDefaults.synchronize()
        }
    }

    public subscript<T: Model>(model key: Key) -> T? {
        get {
            if let data: Data = self[object: key] {
                return try? T.decoded(data)
            }
            return nil
        }
        set {
            guard
                let model = newValue,
                let data = try? model.encoded()
            else {
                remove(for: key)
                return
            }
            self[object: key] = data
        }
    }

    public func remove(for key: Key) {
        userDefaults.removeObject(forKey: key.cacheEncoded())
        userDefaults.synchronize()
    }
}
