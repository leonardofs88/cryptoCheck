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
        let initialViewController = MainViewController()
        initialViewController.setCoordinator(self)
        children.append(initialViewController)
        navigationController.pushViewController(initialViewController, animated: true)
    }

    func showDetailsView(with data: PriceModel) {
        let detailsViewController = DetailsViewController()
        detailsViewController.setData(price: data)
        detailsViewController.setCoordinator(self)
        children.append(detailsViewController)
        navigationController.pushViewController(detailsViewController, animated: true)
    }

    func pop() {
        let popLast = children.popLast()
        if let popLast {
            navigationController.popViewController(animated: true)
        }
    }
}
