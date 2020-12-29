//
//  HIPAPI.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation

open class HIPAPI<SomeSession: Session>: API {
    public let session: SomeSession

    public init(
        base: String,
        session: SomeSession,
        interceptor: APIInterceptor,
        networkMonitor: NetworkMonitor? = nil
    ) {
        self.session = session
        super.init(
            base: base,
            networking: AlamofireNetworking(),
            interceptor: interceptor,
            networkMonitor: networkMonitor
        )
    }
}
