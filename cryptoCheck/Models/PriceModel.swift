//
//  PriceModel.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 26/10/2025.
//

import Foundation

struct PriceModel: Codable, Identifiable {
    let eventType: String         // "e"
    let eventTime: Date           // "E"
    let symbol: String            // "s"
    let priceChange: String       // "p"
    let priceChangePercent: String // "P"
    let weightedAvgPrice: String  // "w"
    let firstTradePrice: String   // "x"
    let lastPrice: String         // "c"
    let lastQuantity: String      // "Q"
    let bestBidPrice: String      // "b"
    let bestBidQuantity: String   // "B"
    let bestAskPrice: String      // "a"
    let bestAskQuantity: String   // "A"
    let openPrice: String         // "o"
    let highPrice: String         // "h"
    let lowPrice: String          // "l"
    let baseVolume: String        // "v"
    let quoteVolume: String       // "q"
    let openTime: Date            // "O"
    let closeTime: Date           // "C"
    let firstTradeId: Int         // "F"
    let lastTradeId: Int          // "L"
    let tradeCount: Int           // "n"

    var id: String { symbol } // helpful for SwiftUI

    enum CodingKeys: String, CodingKey {
        case eventType = "e"
        case eventTime = "E"
        case symbol = "s"
        case priceChange = "p"
        case priceChangePercent = "P"
        case weightedAvgPrice = "w"
        case firstTradePrice = "x"
        case lastPrice = "c"
        case lastQuantity = "Q"
        case bestBidPrice = "b"
        case bestBidQuantity = "B"
        case bestAskPrice = "a"
        case bestAskQuantity = "A"
        case openPrice = "o"
        case highPrice = "h"
        case lowPrice = "l"
        case baseVolume = "v"
        case quoteVolume = "q"
        case openTime = "O"
        case closeTime = "C"
        case firstTradeId = "F"
        case lastTradeId = "L"
        case tradeCount = "n"
    }
}
