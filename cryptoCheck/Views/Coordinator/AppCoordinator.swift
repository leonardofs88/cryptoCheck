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
    var children: [UIViewController] = []

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let initialViewController = MainViewController<PriceModel>()
        initialViewController.setCoordinator(self)
        children.append(initialViewController)
        navigationController.pushViewController(initialViewController, animated: true)
    }

    func showDetailsView(for symbol: String) {
        let detailsViewController = DetailsViewController()
        children.append(detailsViewController)
        detailsViewController.setData(symbol: symbol)
        navigationController.pushViewController(detailsViewController, animated: true)
    }

    func pop() {
        if children.popLast() != nil {
            navigationController.popViewController(animated: true)
        }
    }
}
