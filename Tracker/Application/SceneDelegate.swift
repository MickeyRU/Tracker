//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Павел Афанасьев on 16.06.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        let mainTabBarController = MainTabBarController()
        window.rootViewController = mainTabBarController
        self.window = window
        window.makeKeyAndVisible()
    }
}
