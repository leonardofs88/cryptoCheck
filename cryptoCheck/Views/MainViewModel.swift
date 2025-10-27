//
//  MainViewModel.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 27/10/2025.
//

import Factory
import Combine
import Foundation

class MainViewModel: MainViewModelProtocol {
    @Injected(\.webSocketManager) var webSocketManager

    private(set) var cancellables: Set<AnyCancellable> = []
    private(set) var sourcePublisher: PassthroughSubject<[String:PriceModel], Never> = .init()

    init() {
        startObsevingSocket()
    }

    func sentMessage(for items: [String]) {
        let symbols = items.map { $0.lowercased() + "@ticker"}
        webSocketManager.sendMessage(with: WebSocketBody(method: .subscribe, params: symbols))
    }

    func startObsevingSocket() {
        webSocketManager.setupWebSocket(portType: .primary)
        webSocketManager.managedItem
            .receive(on: RunLoop.main)
            .compactMap(\.?.data)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] item in
                self?.sourcePublisher.send([item.symbol:item])
            }
            .store(in: &cancellables)
    }
}
