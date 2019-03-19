//
//  NetworkReachability.swift
//  Pods
//
//  Created by Eray on 5.10.2018.
//

import Foundation

// TODO: Will be reviewed.
public enum ReachabilityStatus {
    case unknown
    case notReachable
    case reachable
}

public protocol ReachabilityStatusListener: class {
    func reachabilityManager(
        _ manager: Reachability,
        didChangeStatus status: ReachabilityStatus
    )
}

public protocol Reachability {
    var isReachable: Bool { get }
    var status: ReachabilityStatus { get }
    
    func startListening()
    func stopListening()
    
    func addListener(_ listener: ReachabilityStatusListener)
    func remove(_ listener: ReachabilityStatusListener)
}
