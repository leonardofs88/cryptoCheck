//
//  WebSocketManagerProtocol.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 26/10/2025.
//

import Foundation
import Combine

protocol WebSocketManagerProtocol<T>: URLSessionWebSocketDelegate {
    // swiftlint:disable:next type_name
    associatedtype T = Codable

    var reachabilityHelper: ReachabilityMonitorHelperProtocol { get }
    var connectionMonitor: ReachabilityMonitorHelper { get }
    var cancellables: Set<AnyCancellable> { get }
    var session: URLSession { get }
    var webSocketTask: URLSessionWebSocketTask? { get }
    var lastMessage: URLSessionWebSocketTask.Message? { get }
    var managedItem: PassthroughSubject<T?, WebSocketError> { get }
    var webSocketActionState: CurrentValueSubject<WebSocketActionState, Never> { get }
    var endpoint: Endpoint { get }
    var timer: Timer? { get }
    var retrySendCount: Int { get }
    var retryConnectCount: Int { get }

    func setupWebSocket(portType: Port)
    func sendMessage(with body: WebSocketBody)
}
