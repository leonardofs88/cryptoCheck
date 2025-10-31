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
    var sourcePublisher: PassthroughSubject<[String:T], Never> { get }

    func startObsevingSocket()
    func sendMessage(for items: [String])
}
