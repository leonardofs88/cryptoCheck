//
//  SceneDelegate.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 25/10/2025.
//

import UIKit
import Factory
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: CoordinatorProtocol?
    private var cancellable: AnyCancellable?

    @Injected(\.reachabilityHelper) private var reachabilityHelper

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let winScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: winScene)

        let mainNavigationViewController = UINavigationController()
        mainNavigationViewController.navigationBar.tintColor = .appText
        coordinator = AppCoordinator(navigationController: mainNavigationViewController)
        coordinator?.start()
        reachabilityHelper.startMonitoring()
        listenToReachability()

        window?.rootViewController = mainNavigationViewController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func listenToReachability() {
        cancellable = reachabilityHelper
            .networkStatus
            .receive(on: DispatchQueue.main)
            .sink { reachability in
                switch reachability {
                case .notReachable, .unknown:
                    self.coordinator?.showOfflineMessage()
                case .reachable:
                    self.coordinator?.hideOfflineMessage()
                }
            }
    }
}
