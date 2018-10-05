//
//  AlamofireReachability.swift
//  Pods
//
//  Created by Eray on 5.10.2018.
//

import Alamofire

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

class AlamofireNetworkingReachability: Reachability {
    private static let baseURLString = "github.com"
    private let manager = Alamofire.NetworkReachabilityManager(host: baseURLString)
    private var listeners = [ReachabilityStatusListener]()
    
    var status: ReachabilityStatus {
        guard let networkStatus = manager?.networkReachabilityStatus else {
            return .unknown
        }

        return ReachabilityStatus.mapped(from: networkStatus)
    }

    var isReachable: Bool {
        guard let manager = manager else {
            return false
        }
        
        return manager.isReachable
    }
    
    func startListening() {
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
    
    func stopListening() {
        manager?.stopListening()
    }
    
    func addListener(_ listener: ReachabilityStatusListener) {
        listeners.append(listener)
    }
    
    func remove(_ listener: ReachabilityStatusListener) {
        listeners = listeners.filter() { $0 !== listener }
    }
}
