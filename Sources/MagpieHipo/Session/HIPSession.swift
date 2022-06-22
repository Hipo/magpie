//
//  HIPSession.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation
import MacaroonUtils
import MagpieCore

open class HIPSession<
    SomeAuthCredential,
    SomeAuthUser,
    SomeSecureCache: HIPSessionSecureCache,
    SomeCache: HIPSessionCache
>: Session
where
    SomeSecureCache.SomeAuthCredential == SomeAuthCredential,
    SomeCache.SomeAuthUser == SomeAuthUser {
    public private(set) var authCredential: SomeAuthCredential?
    public private(set) var authUser: SomeAuthUser

    public let secureCache: SomeSecureCache
    public let cache: SomeCache

    public init(
        secureCache: SomeSecureCache,
        cache: SomeCache
    ) {
        self.authCredential = secureCache.authCredential
        self.authUser = cache.authUser ?? SomeAuthUser.asAnonymous()
        self.secureCache = secureCache
        self.cache = cache
    }

    open func hasAuthorization() -> Bool {
        return authCredential != nil
    }

    open func authorize(_ newAuthCredential: SomeAuthCredential) {
        authCredential = newAuthCredential
        secureCache.authCredential = newAuthCredential
    }

    open func identify(_ newAuthUser: SomeAuthUser) {
        authUser = newAuthUser
        cache.authUser = newAuthUser
    }

    open func deauthorize() {
        authUser = SomeAuthUser.asAnonymous()
        cache.authUser = nil

        authCredential = nil
        secureCache.authCredential = nil
    }

    open func verify(_ endpoint: EndpointOperatable) {
        if let authCredential = authCredential {
            endpoint.setAdditionalHeader(AuthorizationTokenHeader(authCredential.token))
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

public protocol AuthCredential: ResponseModel {
    var token: String { get }
}

public protocol AuthUser: ResponseModel {
    var isAnonymous: Bool { get }

    static func asAnonymous() -> Self
}

public protocol HIPSessionSecureCache: AnyObject {
    associatedtype SomeAuthCredential: AuthCredential

    var authCredential: SomeAuthCredential? { get set }
}

public protocol HIPSessionCache: AnyObject {
    associatedtype SomeAuthUser: AuthUser

    var authUser: SomeAuthUser? { get set }
}
