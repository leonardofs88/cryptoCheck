//
//  CoordinatorProtocol.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 27/10/2025.
//

import Foundation
import UIKit

protocol CoordinatorProtocol: AnyObject {
    var children: [UIViewController] { get set }

    var navigationController: UINavigationController { get set }

    func start()

    func pop()

    func showDetailsView(for symbol: String)
    
    func showOfflineMessage()

    func hideOfflineMessage()
}
