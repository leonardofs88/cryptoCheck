//
//  WebSocketManager.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 25/10/2025.
//

import Foundation
import Combine

enum WebSocketError: Error {
    case badResponse
    case invalidURL
    case disconnected
    case timeOut
    case decodeError(String)
    case unknown(String?)
}

protocol WebSocketManagerProtocol: NSObject, URLSessionWebSocketDelegate {
    // swiftlint:disable:next type_name
    associatedtype T = Codable
    var cancellables: Set<AnyCancellable> { get }
    var session: URLSession { get }
    var webSocketTask: URLSessionWebSocketTask? { get }
    var lastMessage: URLSessionWebSocketTask.Message? { get }
    var prices: PassthroughSubject<T?, WebSocketError> { get }
    var connectionStatePublisher: PassthroughSubject<WebSocketConnectionState, WebSocketError> { get }
    var webSocketConnectionState: WebSocketConnectionState { get }
}

class WebSocketManager<T: Codable>: NSObject, URLSessionWebSocketDelegate {
    private lazy var connectionMonitor = ReachabilityMonitorHelper()
    private lazy var cancellables: Set<AnyCancellable> = []
    private lazy var session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    private var webSocketTask: URLSessionWebSocketTask?
    private(set) var lastMessage: URLSessionWebSocketTask.Message?
    private(set) var managedItem: PassthroughSubject<T?, WebSocketError> = .init()
    private(set) var webSocketConnectionState: CurrentValueSubject<WebSocketConnectionState, WebSocketError> = .init(.closed(nil))
    private let endpoint: Endpoint
    private var timer: Timer?
    private var retrySendCount = 0
    private var retryConnectCount = 0

    init(endpoint: Endpoint = .stream) {
        self.endpoint = endpoint

        super.init()

        observeConnectionMonitor()
        observeWebSocketConnection()

//        managedItem
//            .receive(on: RunLoop.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .finished:
//                    break
//                case .failure(let failure):
//                    self?.disconnect(failure.localizedDescription)
//                }
//            }, receiveValue: { item in
//                if let item {
//                    print("===== RECEIVED ITEM: \(item) =====")
//                }
//            })
//            .store(in: &cancellables)
    }

    private func observeWebSocketConnection() {
        webSocketConnectionState
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("===== CONNECTION STATE ERROR: \(error) =====")
                }
            } receiveValue: { [weak self] state in
                switch state {
                case .closed(let reason):
                    print("==== CONNECTION STATE CLOSE REASON: \(reason ?? "No reason") =====")
                case .closing:
                    print("==== CONNECTION IS CLOSING ====")
                case .connected:
                    print("==== CONNECTION IS ESTABLISHED ====")
                    self?.sendMessage(
                        with: WebSocketBody(
                            method: .subscribe,
                            params: ["adausdt@ticker", "ethusdt@ticker", "btcusdt@ticker"]
                        )
                    )
                case .trying:
                print("==== TRYING CONNECTION ====")
                }
            }
            .store(in: &cancellables)
    }

    private func observeConnectionMonitor() {
        print("===== START OBSERVING CONNECTION MONITOR =====")
        connectionMonitor.startMonitoring()
        connectionMonitor
            .networkStatus
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .notReachable:
                    print("===== CONNECTION MONITOR NOT REACHABLE =====")
                    disconnect("Retrying connection...")
                case .reachable:
                    print("===== CONNECTION MONITOR REACHABLE =====")
                    self.retrySendCount = 0
                    self.retryConnectCount = 0
                    self.setupWebSocket(for: self.endpoint)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    private func setupWebSocket(for endpoint: Endpoint, portType: Port = .primary) {
        guard let request = WebSocketRequest(port: portType).getRequest(for: endpoint) else { return }
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        webSocketConnectionState.send(.trying)
        startPing()
        sendPing()
        print("===== WEBSOCKET CONNECTING ON PORT \(portType.rawValue) =====")
    }

    private func startPing() {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(
                timeInterval: 20.0,
                target: self,
                selector: #selector(self.sendPing),
                userInfo: nil,
                repeats: true
            )
        }
    }

    @objc private func sendPing() {
        webSocketTask?.sendPing { [weak self] error in
            if let error {
                print("===== PING ERROR =====")
                print("===== ERROR: \(error.localizedDescription) =====")
                self?.disconnect("Retrying...")
                self?.retryConnectCount += 1
                return
            }

            print("===== PING SENT =====")
        }
    }

    func cancelPing() {
        DispatchQueue.main.async {
            print("===== PING INVALIDATED =====")
            self.timer?.invalidate()
            self.timer = nil
        }
    }

    private func sendMessage(with body: WebSocketBody) {
        guard let bodyString = body.asString() else { return }
        guard retrySendCount < 100 else {
            disconnect("Max retry send count reached")
            return
        }

        print("===== SENDING MESSAGE =====")
        webSocketTask?.send(.string(bodyString)) { [weak self] error in
            if let error {
                print("===== SEND MESSAGE ERROR: \(error.localizedDescription) =====")
                self?.sendMessage(with: body)
                self?.retrySendCount += 1
                return
            }
            self?.retrySendCount = 0

            print("===== MESSAGE SENT =====")
            self?.receiveMessage()
        }
    }

    private func unsubscribe(items: [String]) {
        sendMessage(
            with: WebSocketBody(
                method: .unsubscribe,
                params: ["adausdt@ticker", "ethusdt@ticker", "btcusdt@ticker"]
            )
        )
        webSocketConnectionState.send(.closing)
    }

    private func receiveMessage() {
        webSocketTask?
            .receive { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let message):
                    print("===== RECEIVED MESSAGE =====")
                    handleMessage(message)
                    receiveMessage()
                case .failure(let failure):
                    print("===== ERROR RECEIVING MESSAGE =====")
                    print("===== ERROR: \(failure.localizedDescription) =====")
                    self.disconnect(failure.localizedDescription)
                }
            }
    }

    func disconnect(_ message: String, withRetry: Bool = true) {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        webSocketConnectionState.send(.closed(message))
        cancelPing()
        print("===== WEBSOCKET DISCONNECTED =====")
        if withRetry, retryConnectCount < 10 {
            print("===== RETRYING WEBSOCKET CONNECTION =====")
            setupWebSocket(for: endpoint, portType: retryConnectCount < 5 ? .primary : .secondary)
        } else {
            print("===== MAX RETRY REACHED ======")
            print("===== AWAITING RECONNECTION ======")
        }
    }

    func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        do {
            switch message {
            case .string(let string):
                managedItem.send(.some(try JSONDecoder().decode(T.self, from: Data(string.utf8))))
            case .data(let data):
                managedItem.send(.some(try JSONDecoder().decode(T.self, from: data)))
            default:
                managedItem.send(completion: .failure(WebSocketError.badResponse))
            }
        } catch {
            if let decodingError = (error as? DecodingError)?.localizedDescription {
                managedItem.send(completion: .failure(WebSocketError.decodeError(decodingError)))
            } else {
                managedItem.send(completion: .failure(WebSocketError.unknown(error.localizedDescription)))
            }
        }
    }

    // MARK: - URLSessionWebSocketDelegate functions
    // Cannot be in an extension
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        guard webSocketConnectionState.value == .trying else { return }
        if webSocketTask == self.webSocketTask {
            webSocketConnectionState.send(.connected)
        }
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        let reasonDescription = if let reason {
            String(data: reason, encoding: .utf8) ?? "No reason provided"
        } else {
            "No reason provided"
        }

        DispatchQueue.main.async {
            self.disconnect("\(reasonDescription), code: \(closeCode)")
            self.cancelPing()
        }
    }
}

enum WebSocketConnectionState: Hashable {
    case trying
    case connected
    case closing
    case closed(String?)
}

extension String {
    static var domain: String {
        "stream.binance.com"
    }
}
