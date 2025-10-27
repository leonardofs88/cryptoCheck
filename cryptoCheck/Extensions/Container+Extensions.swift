//
//  Container+Extensions.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 25/10/2025.
//

import Foundation
import Factory

extension Container {
    var reachabilityHelper: Factory<ReachabilityMonitorHelperProtocol> {
        self { ReachabilityMonitorHelper() }
    }

    var webSocketManager: Factory<WebSocketManager<StreamWrapper>> {
        self { WebSocketManager() }
    }
}
