//
//  WebSocketManager.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 25/10/2025.
//

import Foundation
import Network
import Combine
import Factory

class WebSocketManager<T: Codable>: NSObject, WebSocketManagerProtocol {
    let endpoint: Endpoint

    private(set) var webSocketRequest: WebSocketRequest?
    private(set) var lastMessageSent: WebSocketBody?

    @LazyInjected(\.reachabilityHelper) private(set) var reachabilityHelper

    private(set) lazy var cancellables: Set<AnyCancellable> = []
    private(set) lazy var session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

    private(set) var webSocketTask: URLSessionWebSocketTask?
    private(set) var managedItem: PassthroughSubject<T?, WebSocketError> = .init()
    private(set) var webSocketActionState: CurrentValueSubject<WebSocketActionState, Never> = .init(.closed)
    private(set) var timer: Timer?
    private(set) var retrySendCount = 0
    private(set) var retryConnectCount = 0

    // MARK: - Init
    init(endpoint: Endpoint = .stream) {
        self.endpoint = endpoint
        super.init()

        observeReachability()
        observeWebSocketConnection()
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Public functions
    func setupWebSocket(portType: Port = .primary) {
        let webSocketRequest = if let webSocketRequest {
            webSocketRequest
        } else {
            WebSocketRequest(port: portType)
        }

        guard let request = webSocketRequest.getRequest(for: .stream) else { return }
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        webSocketActionState.send(.tryingConnection)
        startPing()
        sendPing()
        self.webSocketRequest = webSocketRequest
        print(":::", #function, "===>> WEBSOCKET CONNECTING ON PORT \(portType.rawValue) ||")
    }

    func sendMessage(with body: WebSocketBody) {
        guard let bodyString = body.asString() else { return }
        guard retrySendCount < 100 else {
            disconnect("Max retry send count reached")
            return
        }

        if webSocketActionState.value == .closed {
            setupWebSocket()
            sendMessage(with: body)
        } else {
            webSocketTask?.send(.string(bodyString)) { [weak self] error in
                guard let self else { return }
                if let error {
                    webSocketActionState.send(
                        .errorSendingMessage(
                            WebSocketError.unknown(
                                error.localizedDescription
                            )
                        )
                    )
                    sendMessage(with: body)
                    retrySendCount += 1

                    print(":::", #function, "===>> SEND MESSAGE ERROR: \(error.localizedDescription) ||")
                    return
                }

                retrySendCount = 0
                self.lastMessageSent = body
                webSocketActionState.send(.messageSent)
                receiveMessage()
            }
        }
    }

    func disconnect(_ message: String, withRetry: Bool = true) {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        webSocketActionState.send(.closed)
        cancelPing()
        print(":::", #function, "===>> WEBSOCKET DISCONNECTED ||")
        if withRetry, retryConnectCount < 10 {
            print(":::", #function, "===>> RETRYING WEBSOCKET CONNECTION ||")
            setupWebSocket(portType: retryConnectCount < 5 ? .primary : .secondary)
        } else {
            print(":::", #function, "===>> MAX RETRY REACHED =||")
            print(":::", #function, "===>> AWAITING RECONNECTION =||")
        }
    }

    // MARK: - Private functions
    private func observeWebSocketConnection() {
        webSocketActionState
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink { state in
                switch state {
                case .closed:
                    print(":::", #function, "===>> CONNECTION STATE CLOSE ||")
                case .connected:
                    print(":::", #function, "===>> CONNECTION IS ESTABLISHED ||")
                case .tryingConnection:
                    print(":::", #function, "===>> TRYING CONNECTION ||")
                case .messageSent:
                    print(":::", #function, "===>> MESSAGE SENT ||")
                case .errorSendingMessage(let error):
                    print(":::", #function, "===>> ERROR SENDING MESSAGE \(error.localizedDescription) ||")
                }
            }
            .store(in: &cancellables)
    }

    private func observeReachability() {
        print(":::", #function, "===>> START OBSERVING CONNECTION MONITOR ||")
        reachabilityHelper.startMonitoring()
        reachabilityHelper
            .networkStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .notReachable, .unknown:
                    print(":::", #function, "===>> CONNECTION MONITOR NOT REACHABLE ||")
                    disconnect("Retrying connection...")
                case .reachable:
                    print(":::", #function, "===>> CONNECTION MONITOR REACHABLE ||")
                    self.retrySendCount = 0
                    self.retryConnectCount = 0
                    if self.webSocketActionState.value == .closed, let lastMessageSent = self.lastMessageSent {
                        self.setupWebSocket()
                        self.sendMessage(with: lastMessageSent)
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func startPing() {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(
                timeInterval: 15.0,
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
                print(":::", #function, "===>> PING ERROR ||")
                print(":::", #function, "===>> ERROR: \(error.localizedDescription) ||")
                self?.disconnect("Retrying...")
                self?.retryConnectCount += 1
                return
            }

            print(":::", #function, "===>> PING SENT ||")
        }
    }

    private func cancelPing() {
        DispatchQueue.main.async {
            print(":::", #function, "===>> PING INVALIDATED ||")
            self.timer?.invalidate()
            self.timer = nil
        }
    }

    private func receiveMessage() {
        webSocketTask?
            .receive { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let message):
                    print(":::", #function, "===>> RECEIVED MESSAGE ||")
                    handleMessage(message)
                    receiveMessage()
                case .failure(let failure):
                    print(":::", #function, "===>> ERROR RECEIVING MESSAGE ||")
                    print(":::", #function, "===>> ERROR: \(failure.localizedDescription) ||")
                    self.disconnect(failure.localizedDescription)
                }
            }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        do {
            switch message {
            case .string(let string):
                if string.contains("result") {
                    let result = try JSONDecoder().decode(WebSocketResult.self, from: Data(string.utf8))
                    print(":::", #function, "===>> RESULT FROM SEND MESSAGE: \(result) ||")
                } else {
                    managedItem.send(.some(try JSONDecoder().decode(T.self, from: Data(string.utf8))))
                }
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
        guard webSocketActionState.value == .tryingConnection else { return }
        if webSocketTask == self.webSocketTask {
            DispatchQueue.main.async {
                self.webSocketActionState.send(.connected)
            }
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

enum WebSocketActionState: Hashable {
    case tryingConnection
    case connected
    case messageSent
    case errorSendingMessage(WebSocketError)
    case closed
}

enum WebSocketError: Error, Hashable {
    case badResponse
    case invalidURL
    case disconnected
    case timeOut
    case decodeError(String)
    case unknown(String?)
}

struct WebSocketResult: Codable {
    let id: String
    let result: String?
}
