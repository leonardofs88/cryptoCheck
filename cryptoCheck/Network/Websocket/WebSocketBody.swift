//
//  WebSocketBody.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 26/10/2025.
//

import Foundation

struct WebSocketBody: Codable, Identifiable {
    let method: String
    let params: [String]
    let id: String

    init(method: WebSocketRequestMethod, params: [String]) {
        self.method = method.rawValue.uppercased()
        self.params = params
        id = UUID().uuidString
    }

    func asString() -> String? {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8)
        else { return "" }
        return string
    }

    func asData() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
