//
//  String+Extensions.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 25/10/2025.
//

import Foundation

extension String {

    static var pingHost: String {
        "www.apple.com"
    }

    static var networkMonitorQueue: String {
        "networkMonitorQueue"
    }

    static var domain: String {
        "stream.binance.com"
    }
}

extension String {
    var snakeCased: String {
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(startIndex..., in: self)
        let snakeCase = regex.stringByReplacingMatches(
            in: self,
            options: [],
            range: range,
            withTemplate: "$1_$2"
        )
        return snakeCase
    }
}
