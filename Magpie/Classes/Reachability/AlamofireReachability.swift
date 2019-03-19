//
//  AlamofireReachability.swift
//  Pods
//
//  Created by Eray on 5.10.2018.
//

import Alamofire

// TODO: Will be reviewed.
extension ReachabilityStatus {
    static func mapped(
        from networkStatus: NetworkReachabilityManager.NetworkReachabilityStatus
        ) -> ReachabilityStatus {
        switch networkStatus {
        case .unknown,
             .notReachable:
            return .notReachable
        case .reachable:
            return .reachable
        }
    }
}

public class AlamofireReachability: Reachability {
    private static let baseURLString = "github.com"
    private let manager = Alamofire.NetworkReachabilityManager(host: baseURLString)
    private var listeners = [ReachabilityStatusListener]()
    
    public init() { }
    
    public var status: ReachabilityStatus {
        guard let networkStatus = manager?.networkReachabilityStatus else {
            return .unknown
        }

        return ReachabilityStatus.mapped(from: networkStatus)
    }

    public var isReachable: Bool {
        guard let manager = manager else {
            return false
        }
        
        return manager.isReachable
    }
    
    public func startListening() {
        manager?.startListening()
        
        manager?.listener = { status in
            self.notifyListeners(with: status)
        }
    }
    
    private func notifyListeners(with networkStatus: NetworkReachabilityManager.NetworkReachabilityStatus) {
        listeners.forEach{ (aListener) in
            let status = ReachabilityStatus.mapped(from: networkStatus)
                
            aListener.reachabilityManager(self, didChangeStatus: status)
        }
    }
    
    public func stopListening() {
        manager?.stopListening()
    }
    
    public func addListener(_ listener: ReachabilityStatusListener) {
        listeners.append(listener)
    }
    
    public func remove(_ listener: ReachabilityStatusListener) {
        listeners = listeners.filter() { $0 !== listener }
    }
}
