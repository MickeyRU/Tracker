//
//  MainTabBarController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 18.06.2023.
//

import UIKit

final class MainTabBarController: UITabBarController {
    private let trackersViewController = TrackersViewController()
    private let statisticsViewController = StatisticsViewController()
    
    private var trackerNavigationController: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackerNavigationController = UINavigationController(rootViewController: trackersViewController)
        viewControllers = [trackerNavigationController, statisticsViewController]
        setupTabBarItems()
    }
    
    private func setupTabBarItems() {
        trackersViewController.tabBarItem = UITabBarItem(title: "Трекер",
                                                         image: Images.trackerTabBarImage,
                                                         selectedImage: nil)
        statisticsViewController.tabBarItem = UITabBarItem(title: "Статистика",
                                                           image: Images.statisticsTabBarImage,
                                                           selectedImage: nil)
    }
}
