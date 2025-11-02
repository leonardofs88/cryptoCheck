//
//  MainViewModelProtocol.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 27/10/2025.
//

import Combine

protocol MainViewModelProtocol<T> {
    // swiftlint:disable:next type_name
    associatedtype T = Codable
    // swiftlint:disable:next type_name
    associatedtype W = Codable

    var cancellables: Set<AnyCancellable> { get }
    var webSocketManager: any WebSocketManagerProtocol<W> { get }
    var sourcePublisher: PassthroughSubject<T, Never> { get }

    func startObsevingSocket()
    func sendMessage(_ method: WebSocketRequestMethod, for items: [String]?)
}
