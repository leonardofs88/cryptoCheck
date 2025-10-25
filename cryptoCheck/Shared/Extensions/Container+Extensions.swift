//
//  Container+Extensions.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 25/10/2025.
//

import Foundation
import Factory

extension Container {
    var connectionHelper: Factory<ConnectionMonitorHelper> {
        self { ConnectionMonitorHelper() }
    }
}
