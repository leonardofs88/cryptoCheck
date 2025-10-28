//
//  MainViewModelProtocol.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 27/10/2025.
//

import Combine

protocol MainViewModelProtocol {
    // swiftlint:disable:next type_name
    associatedtype T = Codable

    var cancellables: Set<AnyCancellable> { get }
    var webSocketManager: any WebSocketManagerProtocol<T> { get }
    var sourcePublisher: PassthroughSubject<[String:PriceModel], Never> { get }

    func startObsevingSocket()
    func sendMessage(for items: [String])
}
