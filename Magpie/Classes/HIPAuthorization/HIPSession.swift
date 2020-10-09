//
//  HIPSession.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation

open class HIPSession<Credentials: SessionCredentials, AuthenticatedUser: SessionAuthenticatedUser>: Session, SessionUpdatesPublisher {
    public var delegations: [ObjectIdentifier : SessionUpdatesDelegation] = [:]

    public private(set) var credentials: Credentials?
    public private(set) var authenticatedUser: AuthenticatedUser?

    public let keychain: HIPKeychainConvertible
    public let cache: HIPCacheConvertible?

    public init(
        keychain: HIPKeychainConvertible,
        cache: HIPCacheConvertible? = HIPCache()
    ) {
        self.keychain = keychain
        self.cache = cache

        autoAuthorize()
        autoAuthenticate()
    }

    open func hasAuthorization() -> Bool {
        return credentials != nil
    }

    open func authorize(_ credentials: Credentials) throws {
        self.credentials = credentials
        notifyDelegates { $0.sessionDidAuthorize(self) }

        try keychain.set(credentials, for: Keys.credentials)
    }

    open func autoAuthorize() {
        credentials = try? keychain.getModel(for: Keys.credentials)
    }

    open func deauthorize() throws {
        deauthenticate()

        credentials = nil
        notifyDelegates { $0.sessionDidDeauthorize(self) }

        try keychain.remove(for: Keys.credentials)
    }

    open func hasAuthentication() -> Bool {
        return authenticatedUser != nil
    }

    open func authenticate(_ authenticatedUser: AuthenticatedUser) {
        self.authenticatedUser = authenticatedUser
        notifyDelegates { $0.sessionDidAuthenticate(self) }

        cache?.set(model: authenticatedUser, for: Keys.authenticatedUser)
    }

    open func autoAuthenticate() {
        authenticatedUser = cache?.getModel(for: Keys.authenticatedUser)
    }

    open func deauthenticate() {
        authenticatedUser = nil
        notifyDelegates { $0.sessionDidDeauthenticate(self) }

        cache?.remove(for: Keys.authenticatedUser)
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

open class HIPSessionCredentials: SessionCredentials {
    public let token: String
}

public protocol Session: Printable {
    associatedtype Credentials: SessionCredentials
    associatedtype AuthenticatedUser: SessionAuthenticatedUser

    var credentials: Credentials? { get }
    var authenticatedUser: AuthenticatedUser? { get }

    func hasAuthorization() -> Bool
    func authorize(_ newCredentials: Credentials) throws
    func deauthorize() throws
    func hasAuthentication() -> Bool
    func authenticate(_ newAuthenticatedUser: AuthenticatedUser)
    func deauthenticate()
}

public protocol SessionCredentials: Model {
    var token: String { get }
}

public protocol SessionAuthenticatedUser: Model { }

public protocol SessionUpdatesPublisher: AnyObject {
    var delegations: [ObjectIdentifier: SessionUpdatesDelegation] { get set }

    func add(delegate: SessionUpdatesDelegate)
    func remove(delegate: SessionUpdatesDelegate)
}

extension SessionUpdatesPublisher {
    public func add(delegate: SessionUpdatesDelegate) {
        let id = ObjectIdentifier(delegate)
        delegations[id] = SessionUpdatesDelegation(delegate)
    }

    public func remove(delegate: SessionUpdatesDelegate) {
        let id = ObjectIdentifier(delegate)
        delegations[id] = nil
    }

    public func removeAllDelegates() {
        delegations.removeAll()
    }

    public func notifyDelegates(_ notifier: (SessionUpdatesDelegate) -> Void) {
        delegations.forEach {
            if let delegate = $0.value.delegate {
                notifier(delegate)
            } else {
                delegations[$0.key] = nil
            }
        }
    }
}

public protocol SessionUpdatesDelegate: AnyObject {
    func sessionDidAuthorize<T: Session>(_ session: T)
    func sessionDidDeauthorize<T: Session>(_ session: T)
    func sessionDidAuthenticate<T: Session>(_ session: T)
    func sessionDidDeauthenticate<T: Session>(_ session: T)
}

extension SessionUpdatesDelegate {
    public func sessionDidAuthorize<T: Session>(_ session: T) { }
    public func sessionDidDeauthorize<T: Session>(_ session: T) { }
    public func sessionDidAuthenticate<T: Session>(_ session: T) { }
    public func sessionDidDeauthenticate<T: Session>(_ session: T) { }
}

public class SessionUpdatesDelegation {
    weak var delegate: SessionUpdatesDelegate?

    init(_ delegate: SessionUpdatesDelegate) {
        self.delegate = delegate
    }
}
