//
//  ReachabilityMonitorHelper.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 25/10/2025.
//

import Foundation
import Network
import Combine
import Alamofire

class ReachabilityMonitorHelper: ReachabilityMonitorHelperProtocol {
    typealias NetworkStatus = NetworkReachabilityManager.NetworkReachabilityStatus

    private(set) lazy var networkMonitor: NetworkReachabilityManager? = NetworkReachabilityManager(host: .pingHost)
    private(set) lazy var networkStatus: PassthroughSubject<NetworkStatus, Never> = PassthroughSubject()

    func startMonitoring() {
        networkMonitor?.startListening(onQueue: .networkMonitor) { [weak self] status in
            guard let self else { return }

            DispatchQueue.main.async {
                self.networkStatus.send(status)
            }
        }
    }

    func stopMonitoring() {
        networkMonitor?.stopListening()
    }
}
