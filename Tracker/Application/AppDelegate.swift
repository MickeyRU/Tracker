//
//  AppDelegate.swift
//  Tracker
//
//  Created by Павел Афанасьев on 16.06.2023.
//

import UIKit
import CoreData
import YandexMobileMetrica

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackersCoreDataModel")
        container.loadPersistentStores { decription, error in
            if let error = error as NSError? {
                assertionFailure("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "9f7e559c-11f4-4d39-b2eb-d9f58190d53c") else { 
            return true
        }
        
        YMMYandexMetrica.activate(with: configuration)
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.storyboard = nil
        configuration.sceneClass = UIWindowScene.self
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}
