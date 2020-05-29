//
//  HIPAPI.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation

open class HIPAPI<SomeSession: Session>: API {
    public let session: SomeSession

    public required init(
        session: SomeSession,
        base: String,
        networking: Networking = AlamofireNetworking(),
        interceptor: APIInterceptor? = nil,
        networkMonitor: NetworkMonitor? = nil
    ) {
        self.session = session
        super.init(
            base: base,
            networking: networking,
            interceptor: interceptor ?? HIPAPIInterceptor(session: session),
            networkMonitor: networkMonitor
        )
    }

    @available(*, unavailable)
    public required init(
        base: String,
        networking: Networking,
        interceptor: APIInterceptor? = nil,
        networkMonitor: NetworkMonitor? = nil
    ) {
        fatalError("init(base:networking:interceptor:networkMonitor:) has not been implemented")
    }

    open func authorize(_ credentials: SomeSession.Credentials) {
        session.authorize(credentials)
    }

    open func deauthorize() {
        session.deauthorize()
    }

    open func authenticate(_ authenticatedUser: SomeSession.AuthenticatedUser) {
        session.authenticate(authenticatedUser)
    }

    open func deauthenticate() {
        session.deauthenticate()
    }
}
