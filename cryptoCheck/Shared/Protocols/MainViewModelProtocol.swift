//
//  MainViewModelProtocol.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 27/10/2025.
//

import Combine

protocol MainViewModelProtocol {
    associatedtype T = Codable
    var cancellables: Set<AnyCancellable> { get }
    var webSocketManager: any WebSocketManagerProtocol<T> { get }
    var sourcePublisher: PassthroughSubject<[String:PriceModel], Never> { get }

    func startObsevingSocket()
    func sentMessage(for items: [String])
}
