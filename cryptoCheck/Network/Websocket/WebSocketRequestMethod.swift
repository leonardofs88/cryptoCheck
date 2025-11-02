//
//  WebSocketRequestMethod.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 26/10/2025.
//

import Foundation

enum WebSocketRequestMethod: String, Codable {
    case subscribe
    case unsubscribe
    case listSubscriptions
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
