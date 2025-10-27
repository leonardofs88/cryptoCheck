//
//  StreamWrapper.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 26/10/2025.
//

import Foundation

struct StreamWrapper: Codable, Identifiable {
    var id: String { UUID().uuidString }

    let result: String?
    let data: PriceModel?
    let stream: String?
    let error: WebSocketErrorMessage?
}
