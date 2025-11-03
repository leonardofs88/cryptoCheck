//
//  cryptoCheckTests.swift
//  cryptoCheckTests
//
//  Created by Leonardo Soares on 25/10/2025.
//

import XCTest
import Factory
import Combine

@testable import cryptoCheck

final class cryptoCheckTests: XCTestCase {

    @LazyInjected(\.reachabilityHelper) private var reachabilityHelper

    func testUpdatingConnectionStatus() throws {
        let firstExpectation = expectation(description: "trying connection")
        let secondExpectation = expectation(description: "connected")
        let thirdExpectation = expectation(description: "message sent")
        let testedWebsocketManager = WebSocketManager<StreamWrapper>()

        let cancellable = testedWebsocketManager.webSocketActionState
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink { state in
                switch state {
                case .closed:
                    print(":::", #function, "===>> CONNECTION STATE CLOSE ||")
                case .connected:
                    secondExpectation.fulfill()
                case .tryingConnection:
                    firstExpectation.fulfill()
                case .messageSent:
                    thirdExpectation.fulfill()
                case .errorSendingMessage(let error):
                    print(":::", #function, "===>> ERROR SENDING MESSAGE \(error.localizedDescription) ||")
                }
            }


        testedWebsocketManager.setupWebSocket(portType: .primary)

        XCTAssertNotNil(testedWebsocketManager.webSocketTask)

        testedWebsocketManager.sendMessage(with: WebSocketBody(method: .subscribe, params: ["a", "b", "c"]))

        waitForExpectations(timeout: 5)
        cancellable.cancel()
    }

}
