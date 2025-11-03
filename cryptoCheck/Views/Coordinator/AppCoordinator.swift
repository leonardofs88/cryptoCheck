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

    let offlineAlert = UIAlertController(title: "It seems that we are offline",
                                  message: "Please, check your internet connection and wait to reconnect.",
                                  preferredStyle: .alert)

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

    func showOfflineMessage() {
        navigationController.present(offlineAlert, animated: true)
    }

    func hideOfflineMessage() {
        offlineAlert.dismiss(animated: true)
    }
}
