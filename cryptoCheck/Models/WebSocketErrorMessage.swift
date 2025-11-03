//
//  WebSocketErrorMessage.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 26/10/2025.
//

import Foundation

struct WebSocketErrorMessage: Codable {
    let code: Int
    let message: String

    enum CodingKeys: String, CodingKey {
        case code
        case message = "msg"
    }
}
