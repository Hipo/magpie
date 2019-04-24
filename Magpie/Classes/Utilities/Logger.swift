//
//  Logger.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 23.04.2019.
//

import Foundation
import os.log

public struct Logger {
    enum Category: String {
        case endpoint = "endpoint"
        case response = "response"
        case networkMonitoring = "network.monitoring"
    }

    var filter: LogFilter

    init(_ filter: LogFilter = LogFilter.all()) {
        self.filter = filter
    }
}

extension Logger {
    func log(_ endpoint: Endpoint) {
        switch filter.endpoint {
        case .none:
            return
        case .url:
            log("\nSENDING...\n\(endpoint.description)", .endpoint)
        case .full:
            log("\nSENDING...\n\(endpoint.log)", .endpoint)
        }
    }

    func log(_ response: Response) {
        switch filter.response {
        case .none:
            return
        case .completed:
            log("\nRECEIVED...\n\(response.description)", .response)
        case .failed where response.isFailed:
            log("\nRECEIVED...\n\(response.description)", .response)
        default:
            return
        }
    }

    func log(_ networkMonitor: NetworkMonitor) {
        log("Network is \(networkMonitor.currentStatus.description).", .networkMonitoring)
    }

    func log(_ message: String, _ category: Category) {
        let tag = OSLog(subsystem: "com.hipo.magpie.logger", category: category.rawValue)
        os_log("%{private}@", log: tag, type: .debug, message)
    }
}

public struct LogFilter {
    public enum Endpoint {
        case none /// <note> No endpoint will be printed.
        case url /// <note> '{httpMethod} {url}' will be printed.
        case full /// <note> '{urlRequest}' will be printed.
    }

    public enum Response {
        case none /// <note> No response will be printed.
        case completed /// <note> Every response will be printed.
        case failed /// <note> Only failed responses will be printed.
    }

    public let endpoint: Endpoint
    public let response: Response
    public let networkMonitoring: Bool /// <note> If it is true, then the related logs will be printed.

    public init(
        endpoint: Endpoint,
        response: Response,
        networkMonitoring: Bool
    ) {
        self.endpoint = endpoint
        self.response = response
        self.networkMonitoring = networkMonitoring
    }
}

extension LogFilter {
    public static func all() -> LogFilter {
        return LogFilter(endpoint: .full, response: .completed, networkMonitoring: true)
    }

    public static func none() -> LogFilter {
        return LogFilter(endpoint: .none, response: .none, networkMonitoring: false)
    }
}

protocol LogPrintable {
    var log: String { get }
}
