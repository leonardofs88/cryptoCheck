//
//  CoordinatorProtocol.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 27/10/2025.
//

import Foundation
import UIKit

protocol CoordinatorProtocol {
    // Array de coordinator filhas
    var leaves: [CoordinatorProtocol] { get set }

    // Navigationcontroller que apresentará as viewCOntrollers
    var navigationController: UINavigationController { get set }

    // método que inicia o coordinator e a apresentação.
    func start()
}
