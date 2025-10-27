//
//  WebSocketManagerProtocol.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 26/10/2025.
//

import Foundation
import Combine

protocol WebSocketManagerProtocol: URLSessionWebSocketDelegate {
    // swiftlint:disable:next type_name
    associatedtype T = Codable

    var endpoint: Endpoint { get}
    var reachabilityHelper: ReachabilityMonitorHelperProtocol { get }
    var cancellables: Set<AnyCancellable> { get }
    var session: URLSession { get }
    var webSocketTask: URLSessionWebSocketTask? { get }
    var managedItem: PassthroughSubject<T?, WebSocketError> { get }
    var subscriptionState: PassthroughSubject<WebSocketRequestMethod, Never> { get }
    var webSocketActionState: CurrentValueSubject<WebSocketActionState, Never> { get }
    var timer: Timer? { get }
    var retrySendCount: Int { get }
    var retryConnectCount: Int { get }
}
