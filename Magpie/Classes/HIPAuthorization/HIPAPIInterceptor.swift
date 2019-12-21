//
//  HIPAPIInterceptor.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation

open class HIPAPIInterceptor<Session: HIPSessionConvertible>: HIPAPIInterceptorConvertible {
    public let session: Session

    public required init(session: Session) {
        self.session = session
    }

    open func intercept(_ endpoint: EndpointOperatable) {
        if let credentials = session.credentials {
            endpoint.set(additionalHeader: AuthorizationHeader.token(credentials.token))
        }
    }
}

extension HIPAPIInterceptor {
    /// <mark> CustomStringConvertible
    public var description: String {
        return session.credentials?.description ?? "no interception occured"
    }
}

public protocol HIPAPIInterceptorConvertible: APIInterceptor {
    associatedtype Session: HIPSessionConvertible

    var session: Session { get }
}
