//
//  HIPAPIInterceptor.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation

open class HIPAPIInterceptor<Session: HIPSessionConvertible>: HIPAPISessionInterceptor {
    public let session: Session

    public required init(session: Session) {
        self.session = session
    }

    open func intercept(_ endpoint: EndpointOperatable) {
        endpoint.set(additionalHeader: AcceptHeader.json())
        endpoint.set(additionalHeader: AcceptEncodingHeader.gzip())
        endpoint.set(additionalHeader: ContentTypeHeader.json())

        if let credentials = session.credentials {
            endpoint.set(additionalHeader: AuthorizationHeader.token(credentials.token))
        }
    }
}

extension HIPAPIInterceptor {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return session.credentials?.debugDescription ?? "no interception occured"
    }
}

public protocol HIPAPISessionInterceptor: APIInterceptor {
    associatedtype Session: HIPSessionConvertible

    var session: Session { get }
}
