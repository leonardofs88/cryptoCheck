//
//  MockReachabilityHelper.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 26/10/2025.
//

import Alamofire
import Combine

class MockReachabilityHelper: ReachabilityMonitorHelperProtocol {
    private(set) var networkMonitor: NetworkReachabilityManager?

    private(set) var networkStatus: PassthroughSubject<NetworkStatus, Never> = .init()

    init() {
        networkStatus.send(.unknown)
    }

    func startMonitoring() { }

    func stopMonitoring() { }

}

// For testing purposes
extension ReachabilityMonitorHelperProtocol {
    func setStatus(_ status: NetworkStatus) {
        self.networkStatus.send(status)
    }
}
