//
//  MockedContainer.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 26/10/2025.
//

import Factory

extension Container {
    var reachabilityHelper: Factory<ReachabilityMonitorHelperProtocol> {
        self { MockReachabilityHelper() }
    }
}
