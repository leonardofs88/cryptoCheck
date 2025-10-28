//
//  DispatchQueue+Extensions.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 25/10/2025.
//

import Foundation

extension DispatchQueue {
    static let networkMonitor = DispatchQueue(label: .networkMonitorQueue)
}
