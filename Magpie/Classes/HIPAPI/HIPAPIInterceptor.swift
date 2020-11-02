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
        endpoint.setAdditionalHeader(AcceptHeader.json(), .setIfNotExists)
        endpoint.setAdditionalHeader(AcceptEncodingHeader.gzip(), .setIfNotExists)
        endpoint.setAdditionalHeader(ContentTypeHeader.json(), .setIfNotExists)

        if let credentials = session.credentials {
            endpoint.setAdditionalHeader(AuthorizationHeader.token(credentials.token), .alwaysOverride)
        }
    }

    open func intercept(_ response: Response, for endpoint: EndpointOperatable) -> Bool {
        return false
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
