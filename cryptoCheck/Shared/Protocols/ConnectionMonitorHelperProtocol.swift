//
//  ConnectionMonitorHelperProtocol.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 25/10/2025.
//

import Alamofire
import Combine

protocol ConnectionMonitorHelperProtocol {
    var networkMonitor: NetworkReachabilityManager? { get }
    var networkStatus: PassthroughSubject<NetworkReachabilityManager.NetworkReachabilityStatus, Never> { get }

    func startMonitoring()
    func stopMonitoring()
}
