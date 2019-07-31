//
//  ViewController.swift
//  Magpie
//
//  Created by eraydiler on 09/10/2018.
//  Copyright (c) 2018 eraydiler. All rights reserved.
//

import UIKit
import Magpie
import enum Magpie.Error

class API: Magpie {
    required init(
        base: String,
        networking: Networking,
        networkMonitor: NetworkMonitor? = nil
    ) {
        super.init(base: base, networking: networking, networkMonitor: networkMonitor)

        sharedJsonBodyEncodingStrategy = JSONBodyEncodingStrategy(date: .iso8601, data: .base64)
    }

    convenience init() {
        if #available(iOS 12, *) {
            self.init(base: "#baseUrlString", networking: AlamofireNetworking(), networkMonitor: NWNetworkMonitor())
        } else {
            self.init(base: "#baseUrlString", networking: AlamofireNetworking())
        }
    }
}

extension API {
    @discardableResult
    func authenticate(
        with draft: AuthenticationDraft,
        then handler: @escaping (Response.ModelResult<User>) -> Void
    ) -> EndpointOperatable {
        return Endpoint(path: "#path")
            .httpMethod(.post)
            .httpBody(draft)
            .resultHandler(handler)
            .ignoreResultWhenCancelled(false)
            .ignoreResultWhenDelegatesNotified(false)
            .notifyDelegatesWhenFailedFromUnavailableNetwork(true)
            .buildAndSend(self)
    }
}

enum AnyRequestParameter: String, JSONBodyRequestParameter {
    case email = "email"
    case password = "password"
    case password2 = "password2"
    case isNewUser = "is_new_user"
    case date = "date"

    func sharedValue() -> Value? {
        switch self {
        case .isNewUser:
            return SharedValue(true)
        default:
            return nil
        }
    }
}

struct AuthenticationQuery: Query {
    typealias Key = AnyRequestParameter

    func decoded() -> [Pair]? {
        return [
            Pair(key: .isNewUser, value: .shared)
        ]
    }
}

struct AuthenticationDraft: JSONBody {
    typealias Key = AnyRequestParameter

    let email: String
    let password: String
    let date: Date
    let password2: String?

    init(
        email: String,
        password: String,
        date: Date = Date(),
        password2: String? = nil
    ) {
        self.email = email
        self.password = password
        self.date = date
        self.password2 = password2
    }

    func decoded() -> [Pair]? {
        return [
            Pair(key: .email, value: email),
            Pair(key: .password, value: password),
            Pair(key: .date, value: date),
            Pair(key: .password2, value: password2, policy: .setIfPresent),
            Pair(key: .isNewUser)
        ]
    }
}

struct User: Model {
    let email: String
}

class ViewController: UIViewController {
    let api = API()

    override func viewDidLoad() {
        super.viewDidLoad()

        api.addDelegate(self)

        let draft = AuthenticationDraft(email: "#email", password: "#password")
        api.authenticate(with: draft) { result in
        }
    }
}

extension ViewController: MagpieDelegate {
    func magpie(_ magpie: Magpie, networkMonitor: NetworkMonitor, didConnectVia connection: NetworkConnection, from oldConnection: NetworkConnection) {
    }

    func magpie(_ magpie: Magpie, networkMonitor: NetworkMonitor, didDisconnectFrom oldConnection: NetworkConnection) {
    }

    func magpie(_ magpie: Magpie, endpoint: Endpoint, didFailFromUnavailableNetwork reason: Error) {
    }
}
