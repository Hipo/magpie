//
//  NetworkReachability.swift
//  Pods
//
//  Created by Eray on 5.10.2018.
//

import Foundation

public enum ReachabilityStatus {
    case unknown
    case notReachable
    case reachable
}

protocol ReachabilityStatusListener: class {
    func reachabilityManager(
        _ manager: Reachability,
        didChangeStatus status: ReachabilityStatus
    )
}

protocol Reachability {
    var isReachable: Bool { get }
    var status: ReachabilityStatus { get }
    
    func startListening()
    func stopListening()
//    func notifyListeners()
    
    func addListener(_ listener: ReachabilityStatusListener)
    func remove(_ listener: ReachabilityStatusListener)
}
