//
//  AppDelegate.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 25/10/2025.
//

import UIKit
import Factory

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    @LazyInjected(\.connectionHelper) private var connectionHelper

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Override point for customization after application launch.
        connectionHelper.startMonitoring()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        connectionHelper.stopMonitoring()
    }
}
