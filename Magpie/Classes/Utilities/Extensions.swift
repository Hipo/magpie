//
//  Extensions.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 28.03.2019.
//

import Foundation

extension URLSessionTask {
    var isWaitingForResponse: Bool {
        return state == .running || state == .suspended
    }
}

extension CustomDebugStringConvertible where Self: CustomStringConvertible {
    public var debugDescription: String {
        return description
    }
}

extension Data {
    func toJSON() -> JSON? {
        return (try? JSONSerialization.jsonObject(with: self)) as? JSON
    }

    func toString() -> String {
        if count > 0 {
            return String(data: self, encoding: .utf8) ?? "<unavailable>"
        }
        return "<empty>"
    }
}

extension Optional where Wrapped: CustomStringConvertible {
    var absoluteDescription: String {
        switch self {
        case .none:
            return "<nil>"
        case .some(let wrapped):
            return wrapped.description
        }
    }
}

extension Optional where Wrapped: CustomDebugStringConvertible {
    var absoluteDebugDescription: String {
        switch self {
        case .none:
            return "<nil>"
        case .some(let wrapped):
            return wrapped.debugDescription
        }
    }
}

extension String {
    func dropLastWord(_ k: Int = 1) -> String {
        return split(separator: " ").suffix(k).joined(separator: " ")
    }
}

/// <reference>
/// See https://gist.github.com/shaps80/ba6a1e2d477af0383e8f19b87f53661d
extension URLRequest {
    func asCURL() -> String? {
        guard let url = url else {
            return nil
        }
        let baseCommand = "curl \(url.absoluteString)"
        var command: [String] = []

        if let httpMethod = httpMethod {
            switch httpMethod {
            case "GET":
                command.append(baseCommand)
            case "HEAD":
                command.append("\(baseCommand) --head")
            default:
                command.append("\(baseCommand)")
                command.append("-X \(httpMethod)")
            }
        } else {
            command.append(baseCommand)
        }
        if let body = httpBody {
            if let bodyString = String(data: body, encoding: .utf8) {
                command.append("-d '\(bodyString)'")
            }
        }
        if let headers = allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                command.append("-H '\(key): \(value)'")
            }
        }
        return command.joined(separator: " \\\n\t")
    }
}
