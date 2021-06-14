//
//  HIPAPIInterceptor.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation
import MacaroonUtils
import MagpieCore

open class HIPAPIInterceptor<SomeSession: Session>: APIInterceptor {
    public lazy var application = HIPApplication()
    public lazy var device = HIPDevice()

    public let session: SomeSession

    public required init(session: SomeSession) {
        self.session = session
    }

    open func intercept(_ endpoint: EndpointOperatable) {
        /// <note> HTTP
        endpoint.setAdditionalHeader(AcceptEncodingHeader.gzip(), .setIfNotExists)
        endpoint.setAdditionalHeader(AcceptHeader.json(), .setIfNotExists)

        if !endpoint.type.isMultipart {
            endpoint.setAdditionalHeader(ContentTypeHeader.json(), .setIfNotExists)
        }

        /// <note> Hipo
        endpoint.setAdditionalHeader(AppNameHeader(application), .alwaysOverride)
        endpoint.setAdditionalHeader(AppPackageNameHeader(application), .alwaysOverride)
        endpoint.setAdditionalHeader(AppVersionHeader(application), .alwaysOverride)
        endpoint.setAdditionalHeader(ClientTypeHeader(device), .alwaysOverride)
        endpoint.setAdditionalHeader(DeviceLocaleHeader(device), .alwaysOverride)
        endpoint.setAdditionalHeader(DeviceOSVersionHeader(device), .alwaysOverride)
        endpoint.setAdditionalHeader(DeviceModelHeader(device), .alwaysOverride)

        /// <note> Client
        session.verify(endpoint)
    }

    open func intercept(_ response: Response, for endpoint: EndpointOperatable) -> Bool {
        return false
    }
}

extension HIPAPIInterceptor {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return """
        Intercepting API for session:
        \(session.description)
        """
    }
}
