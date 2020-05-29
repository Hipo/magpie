//
//  HIPAPIInterceptor.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation

open class HIPAPIInterceptor<SomeSession: Session>: HIPAPISessionInterceptor {
    public let session: SomeSession

    public required init(session: SomeSession) {
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
    /// <mark> CustomStringConvertible
    public var description: String {
        return session.credentials?.description ?? "no interception occured"
    }
}

public protocol HIPAPISessionInterceptor: APIInterceptor {
    associatedtype SomeSession: Session

    var session: SomeSession { get }
}
