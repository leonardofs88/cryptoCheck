//
//  WebSocketManager.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 25/10/2025.
//

import Foundation
import Combine

class WebSocketManager<T: Codable> {

    private lazy var cancellables: Set<AnyCancellable> = []
    private var webSocketTask: URLSessionWebSocketTask?
    private(set) var lastMessage: URLSessionWebSocketTask.Message?
    private(set) var prices: PassthroughSubject<T?, Never> = .init()

    let session = URLSession(configuration: .default)
    var counter = 0

    init() {
        setupWebSocket()

        prices
            .receive(on: DispatchQueue.main)
            .sink { value in
                print("Received Value:",value)
            }
            .store(in: &cancellables)
    }

    private func setupWebSocket() {
        guard let url = WebSocketRequest().getRequest(for: .stream) else { return }
        guard let subscribeMessage = WebSocketBody(
            method: .subscribe,
            params: ["adausdt@ticker", "ethusdt@ticker", "btcusdt@ticker"]
        ).asString() else { return }

        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()

        webSocketTask?.send(.string(subscribeMessage)) { [weak self] error in
            if let error {
                print("subscription error:", error.localizedDescription)
                return
            }

            self?.receiveMessage()
        }
    }

    private func receiveMessage() {
        guard counter < 10 else {
            unsubscribe()
            return
        }

        webSocketTask?
            .receive { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let message):
//                    prices.send(handleMessage(message))
                        handleMessage(message)
                    receiveMessage()
                    counter += 1
                case .failure(let failure):
                    print("Websocket failed:", failure.localizedDescription)
                    unsubscribe()
                }
            }
    }

    func unsubscribe() {
        guard let unsubscribeMessage = WebSocketBody(
            method: .unsubscribe,
            params: ["adausdt@ticker", "ethusdt@ticker", "btcusdt@ticker"]
        ).asString() else { return }

        webSocketTask?.send(.string(unsubscribeMessage)) { error in
            if let error {
                print("unsubscription error:", error.localizedDescription)
                return
            }
        }

        disconnect()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }

    func handleMessage(_ message: URLSessionWebSocketTask.Message) {

        do {
            switch message {
            case .string(let string):
                print("string:", string)
//                print("Json as data:", Data(string.utf8))
                    print("Json as object:", try JSONDecoder().decode(StreamWrapper.self, from: Data(string.utf8)))
            case .data(let data):
                    let decoder = try JSONDecoder().decode(StreamWrapper.self, from: data)
                print("Data:", decoder)
            default:
                break
            }

//            return try JSONDecoder().decode(T.self, from: handledData)
        } catch {
            print("Decoding error:", (error as? DecodingError)?.localizedDescription)
//            return nil
        }
    }
}

import Factory

extension Container {
    var webSocketManager: Factory<WebSocketManager<StreamWrapper>> {
        self { WebSocketManager() }
    }
}

struct StreamWrapper: Codable, Identifiable {
    var id: String { UUID().uuidString }

    let result: String?
    let data: PriceModel?
    let stream: String?
}

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

struct WebSocketRequest {
    let domain = "stream.binance.com"
    let scheme: String
    let requestType: String
    let body: Data?
    let port: Int

    init(scheme: Scheme = .wss, requestType: RequestType = .get, body: WebSocketBody? = nil, port: Port = .primary) {
        self.scheme = scheme.rawValue
        self.requestType = requestType.rawValue.uppercased()
        self.body = body?.asData()
        self.port = port.rawValue
    }

    func getRequest(for endpoint: Endpoint) -> URLRequest? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = domain
        components.port = port
        guard let url = components.url else { return nil }

        var request = URLRequest(url: url.appending(path: endpoint.rawValue))
        request.httpMethod = requestType
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body {
            request.httpBody = body
        }
        return request
    }
}

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

enum WebSocketRequestMethod: String {
    case subscribe
    case unsubscribe
}

protocol EndpointProtocol {
    var domain: URL? { get }
    func getURL(for type: Endpoint) -> URLRequest?
}

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
