//
//  HIPSession.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation

open class HIPSession<Credentials: HIPSessionCredentialsConvertible, AuthenticatedUser: HIPSessionAuthenticatedUserConvertible>: HIPSessionConvertible {
    public private(set) var credentials: Credentials?
    public private(set) var authenticatedUser: AuthenticatedUser?

    public let keychain: HIPKeychainConvertible
    public let cache: HIPCacheConvertible

    public init(
        keychain: HIPKeychainConvertible,
        cache: HIPCacheConvertible = HIPCache()
    ) {
        self.keychain = keychain
        self.cache = cache

        autoAuthorize()
        autoAuthenticate()
    }

    open func hasAuthorization() -> Bool {
        return credentials != nil
    }

    open func authorize(_ credentials: Credentials) {
        self.credentials = credentials
        keychain.set(credentials, for: Keys.credentials)
    }

    open func autoAuthorize() {
        credentials = keychain.getModel(for: Keys.credentials)
    }

    open func deauthorize() {
        deauthenticate()

        credentials = nil
        keychain.remove(for: Keys.credentials)
    }

    open func hasAuthentication() -> Bool {
        return authenticatedUser != nil
    }

    open func authenticate(_ authenticatedUser: AuthenticatedUser) {
        self.authenticatedUser = authenticatedUser
        cache.set(authenticatedUser, for: Keys.authenticatedUser)
    }

    open func autoAuthenticate() {
        authenticatedUser = cache.getModel(for: Keys.authenticatedUser)
    }

    open func deauthenticate() {
        authenticatedUser = nil
        cache.remove(for: Keys.authenticatedUser)
    }
}

extension HIPSession {
    public enum Keys: String, HIPKeychainKeyConvertible, HIPCacheKeyConvertible {
        case credentials = "session.credentials"
        case authenticatedUser = "session.authenticated_user"
    }
}

extension HIPSession {
    /// <mark> CustomStringConvertible
    public var description: String {
        return "\(credentials?.description ?? "<no credentials>\n\(authenticatedUser?.description ?? "<no authenticated user>")")"
    }
}

open class HIPSessionCredentials: HIPSessionCredentialsConvertible {
    public let token: String
}

public protocol HIPSessionConvertible: Printable {
    associatedtype Credentials: HIPSessionCredentialsConvertible
    associatedtype AuthenticatedUser: HIPSessionAuthenticatedUserConvertible

    var credentials: Credentials? { get }
    var authenticatedUser: AuthenticatedUser? { get }

    func hasAuthorization() -> Bool
    func authorize(_ credentials: Credentials)
    func deauthorize()
    func hasAuthentication() -> Bool
    func authenticate(_ newAuthenticatedUser: AuthenticatedUser)
    func deauthenticate()
}

public protocol HIPSessionCredentialsConvertible: Model {
    var token: String { get }
}

public protocol HIPSessionAuthenticatedUserConvertible: Model { }
