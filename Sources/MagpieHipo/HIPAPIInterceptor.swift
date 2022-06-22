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
        endpoint.setAdditionalHeader(AcceptGZIPEncodingHeader(), policy: .setIfNotExists)
        endpoint.setAdditionalHeader(AcceptJSONHeader(), policy: .setIfNotExists)

        if !endpoint.type.isMultipart {
            endpoint.setAdditionalHeader(ContentTypeJSONHeader(), policy: .setIfNotExists)
        }

        /// <note> Hipo
        endpoint.setAdditionalHeader(AppNameHeader(application))
        endpoint.setAdditionalHeader(AppPackageNameHeader(application))
        endpoint.setAdditionalHeader(AppVersionHeader(application))
        endpoint.setAdditionalHeader(ClientTypeHeader(device))
        endpoint.setAdditionalHeader(DeviceLocaleHeader(device))
        endpoint.setAdditionalHeader(DeviceOSVersionHeader(device))
        endpoint.setAdditionalHeader(DeviceModelHeader(device))

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
