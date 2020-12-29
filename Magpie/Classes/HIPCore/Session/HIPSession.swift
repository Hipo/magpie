//
//  HIPSession.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation

open class HIPSession<
    SomeAuthCredential: AuthCredential,
    SomeAuthUser: AuthUser,
    SomeSecureCache: SecureCache,
    SomeCache: Cache
>: Session
where
    SomeSecureCache.Key: HIPSessionSecureCacheKey,
    SomeCache.Key: HIPSessionCacheKey {
    public private(set) var authCredential: SomeAuthCredential?
    public private(set) var authUser: SomeAuthUser

    public let secureCache: SomeSecureCache
    public let cache: SomeCache

    private var listenerBoxes: [ObjectIdentifier : HIPSessionListenerBox] = [:]

    public init(
        secureCache: SomeSecureCache,
        cache: SomeCache
    ) {
        self.authCredential = try? secureCache.getModel(for: .authCredential)
        self.authUser = cache.getModel(for: .authUser) ?? SomeAuthUser.asAnonymous()
        self.secureCache = secureCache
        self.cache = cache
    }

    open func hasAuthorization() -> Bool {
        return authCredential != nil
    }

    open func authorize(_ newAuthCredential: SomeAuthCredential) throws {
        authCredential = newAuthCredential
        notifyListeners { $0.sessionDidAuthorize() }

        try secureCache.set(newAuthCredential, for: .authCredential)
    }

    open func deauthorize() throws {
        deauthenticate()

        authCredential = nil
        notifyListeners { $0.sessionDidDeauthorize() }

        try secureCache.remove(for: .authCredential)
    }

    open func hasAuthentication() -> Bool {
        return !authUser.isAnonymous
    }

    open func authenticate(_ newAuthUser: SomeAuthUser) {
        authUser = newAuthUser
        notifyListeners { $0.sessionDidAuthenticate() }

        cache.set(model: newAuthUser, for: .authUser)
    }

    open func deauthenticate() {
        authUser = SomeAuthUser.asAnonymous()
        notifyListeners { $0.sessionDidDeauthenticate() }

        cache.remove(for: .authUser)
    }

    /// <mark> Session
    open func verify(endpoint: EndpointOperatable) {
        if let authCredential = authCredential {
            endpoint.setAdditionalHeader(
                AuthorizationHeader.token(authCredential.token),
                .alwaysOverride
            )
        }
    }
}

extension HIPSession {
    public func add(listener: HIPSessionAuthListener) {
        let id = ObjectIdentifier(listener)
        listenerBoxes[id] = HIPSessionListenerBox(listener)
    }

    public func remove(listener: HIPSessionAuthListener) {
        let id = ObjectIdentifier(listener)
        listenerBoxes[id] = nil
    }

    public func removeAllListeners() {
        listenerBoxes.removeAll()
    }

    public func notifyListeners(_ notifier: (HIPSessionAuthListener) -> Void) {
        listenerBoxes.forEach {
            if let listener = $0.value.listener {
                notifier(listener)
            } else {
                listenerBoxes[$0.key] = nil
            }
        }
    }
}

extension HIPSession {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return """
        \(authCredential?.debugDescription ?? "<no credentials>")
        \(authUser.debugDescription)
        """
    }
}

public protocol AuthCredential: Model {
    var token: String { get }
}

public protocol AuthUser: Model {
    var isAnonymous: Bool { get }

    static func asAnonymous() -> Self
}

public protocol HIPSessionSecureCacheKey: SecureCacheKey {
    static var authCredential: Self { get }
}

public protocol HIPSessionCacheKey: CacheKey {
    static var authUser: Self { get }
}

public protocol HIPSessionAuthListener: AnyObject {
    func sessionDidAuthorize()
    func sessionDidDeauthorize()
    func sessionDidAuthenticate()
    func sessionDidDeauthenticate()
}

extension HIPSessionAuthListener {
    public func sessionDidAuthorize() { }
    public func sessionDidDeauthorize() { }
    public func sessionDidAuthenticate() { }
    public func sessionDidDeauthenticate() { }
}

public class HIPSessionListenerBox {
    weak var listener: HIPSessionAuthListener?

    init(_ listener: HIPSessionAuthListener) {
        self.listener = listener
    }
}
