//
//  ReachabilityMonitorHelperProtocol.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 25/10/2025.
//

import Alamofire
import Combine

protocol ReachabilityMonitorHelperProtocol {
    typealias NetworkStatus = NetworkReachabilityManager.NetworkReachabilityStatus
    
    var networkMonitor: NetworkReachabilityManager? { get }
    var networkStatus: PassthroughSubject<NetworkStatus, Never> { get }

    func startMonitoring()
    func stopMonitoring()
}
