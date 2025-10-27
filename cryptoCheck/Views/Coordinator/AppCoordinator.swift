//
//  AppCoordinator.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 27/10/2025.
//

import Foundation
import UIKit
import Factory

class AppCoordinator: CoordinatorProtocol {
    var leaves: [UIViewController] = []

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let initialViewController = MainViewController()
        navigationController.pushViewController(initialViewController, animated: true)
    }

    func push(_ view: UIViewController) {
        leaves.append(view)
        navigationController.pushViewController(view, animated: true)
    }

    func pop() {
        let last = leaves.popLast()
        last?.navigationController?.popViewController(animated: true)
    }
}

extension Container {
    @MainActor
    var coordinator: Factory<CoordinatorProtocol> {
        self { @MainActor in AppCoordinator(navigationController: UINavigationController()) }
    }
}
