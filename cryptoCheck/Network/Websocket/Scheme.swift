//
//  Scheme.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 26/10/2025.
//

import Foundation

enum Scheme: String {
    case http
    case https
    case wss

    var scheme: String {
        "\(self.rawValue)://"
    }
}

enum Port: Int {
    case primary = 9443
    case secondary = 443
}

enum RequestType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum Endpoint: String {
    case ws
    case stream
}
