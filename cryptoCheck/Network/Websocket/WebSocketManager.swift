//
//  WebSocketManager.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 25/10/2025.
//

import Foundation
import Combine

class WebSocketManager {

    private var webSocketTask: URLSessionWebSocketTask?
    private(set) var lastMessage: URLSessionWebSocketTask.Message?
    private(set) var prices: PassthroughSubject<PriceModel, Never> = .init()

    let url = URL(string: "wss://stream.binance.com:9443")?
        .appendingPathComponent("stream")
        .appending(
            queryItems: [
                URLQueryItem(
                    name: "streams",
                    value: "btcusdt@ticker/ethusdt@ticker/adausdt@ticker"
                ),
                URLQueryItem(
                    name: "timeUnit",
                    value: "MICROSECOND"
                )
            ]
        )

    let session = URLSession(configuration: .default)

    init() {
        setupWebSocket()
    }

    private func setupWebSocket() {
        guard let url else { return }

        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()

        receiveMessage()
    }

    private func receiveMessage() {
        webSocketTask?
            .receive { [weak self] result in
                switch result {
                case .success(let message):
                        switch message {
                        case .string(let string):
                            print("string:", string)
                        case .data(let data):
                            let decoder = try? JSONDecoder().decode(PriceModel.self, from: data)
                            print("Data:", decoder)
                        default:
                            break
                        }
                    self?.receiveMessage()
                case .failure(let failure):
                    print("Websocket failed:", failure.localizedDescription)
                }
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}

import Factory

extension Container {
    var webSocketManager: Factory<WebSocketManager> {
        self { WebSocketManager() }
    }
}


import Foundation

struct StreamWrapper: Codable, Identifiable {
    var id: String { UUID().uuidString }

    let data: [PriceModel]
    let stream: String
}

struct PriceModel: Codable, Identifiable {
    let eventType: String         // "e"
    let eventTime: Date           // "E"
    let symbol: String            // "s"
    let priceChange: Double       // "p"
    let priceChangePercent: Double // "P"
    let weightedAvgPrice: Double  // "w"
    let firstTradePrice: Double   // "x"
    let lastPrice: Double         // "c"
    let lastQuantity: Double      // "Q"
    let bestBidPrice: Double      // "b"
    let bestBidQuantity: Double   // "B"
    let bestAskPrice: Double      // "a"
    let bestAskQuantity: Double   // "A"
    let openPrice: Double         // "o"
    let highPrice: Double         // "h"
    let lowPrice: Double          // "l"
    let baseVolume: Double        // "v"
    let quoteVolume: Double       // "q"
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
