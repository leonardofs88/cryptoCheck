//
//  MainViewModel.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 27/10/2025.
//

import Factory
import Combine
import Foundation

class MainViewModel<T: Codable>: MainViewModelProtocol {

    @Injected(\.webSocketManager) var webSocketManager

    private weak var coordinator: (any CoordinatorProtocol)?

    private(set) var cancellables: Set<AnyCancellable> = []
    private(set) var sourcePublisher: PassthroughSubject<PriceModel, Never> = .init()

    init() {
        listenToWebSocket()
    }

    func sendMessage(_ method: WebSocketRequestMethod = .subscribe, for items: [String]?) {
        let symbols: [String]? = if let items {
            items.map { $0.lowercased() + "@ticker"}
        } else {
            nil
        }

        webSocketManager.sendMessage(with: WebSocketBody(method: method, params: symbols))
    }

    func startObsevingSocket() {
        webSocketManager.setupWebSocket(portType: .primary)
    }

    func listenToWebSocket() {
        webSocketManager.managedItem
            .receive(on: RunLoop.main)
            .compactMap({ $0?.data })
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] item in
                self?.sourcePublisher.send(item)
            }
            .store(in: &cancellables)
    }
}
