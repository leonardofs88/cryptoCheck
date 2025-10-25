//
//  ConnectionHelper.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 25/10/2025.
//

import Foundation
import Network
import Combine
import Alamofire

class ConnectionMonitorHelper: ConnectionMonitorHelperProtocol {
    private(set) lazy var networkMonitor: NetworkReachabilityManager? = NetworkReachabilityManager(host: .pingHost)
    private(set) lazy var networkStatus: PassthroughSubject<NetworkReachabilityManager.NetworkReachabilityStatus, Never> = PassthroughSubject()

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
