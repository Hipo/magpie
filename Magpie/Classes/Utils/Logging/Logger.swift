//
//  Logger.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 23.04.2019.
//

import Foundation
import os.log

struct Logger {
    var logs: [Logs] = [.requests(), .responses(), .networkMonitoring]
}

extension Logger {
    func log(_ request: Request) {
        if logs.contains(.requests(.info)) {
            log("\nSENDING...\n\(request.description)", .requests())
            return
        }
        if logs.contains(.requests(.verbose)) {
            log("\nSENDING...\n\(request.debugDescription)", .requests())
            return
        }
    }

    func log(_ response: Response) {
        if logs.contains(.responses(.error)) {
            log("\nRECEIVED...\n\(response.description)", .responses())
            return
        }
        if logs.contains(.responses(.verbose)) {
            log("\nRECEIVED...\n\(response.description)", .responses())
            return
        }
    }

    func log(_ networkMonitor: NetworkMonitor) {
        log("Network is \(networkMonitor.currentStatus.description)", .networkMonitoring)
    }

    func log(_ message: String, _ logs: Logs) {
        let tag = OSLog(subsystem: "com.hipo.magpie.logs", category: logs.category)
        os_log("%{private}@", log: tag, type: .debug, message)
    }
}

extension Logger: Printable {
    /// <mark> CustomStringConvertible
    var description: String {
        return "[Logs] \(logs.map({ $0.category }).joined(separator: ","))"
    }
}

public enum Logs: Equatable {
    case requests(RequestLogLevel = .verbose)
    case responses(ResponseLogLevel = .verbose)
    case networkMonitoring
}

extension Logs {
    var category: String {
        switch self {
        case .requests:
            return "requests"
        case .responses:
            return "responses"
        case .networkMonitoring:
            return "networkmonitoring"
        }
    }
}

extension Logs {
    public enum RequestLogLevel {
        case info
        case verbose
    }

    public enum ResponseLogLevel {
        case error
        case verbose
    }
}
