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
    private let borderView = UIView()
    
    private var trackerNavigationController: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackerNavigationController = UINavigationController(rootViewController: trackersViewController)
        viewControllers = [trackerNavigationController, statisticsViewController]
        setupTabBarItems()
        borderConfigure()
    }
    
    private func setupTabBarItems() {
        trackersViewController.tabBarItem = UITabBarItem(title: "Трекер",
                                                         image: Images.trackerTabBarImage,
                                                         selectedImage: nil)
        statisticsViewController.tabBarItem = UITabBarItem(title: "Статистика",
                                                           image: Images.statisticsTabBarImage,
                                                           selectedImage: nil)
    }
    
    private func borderConfigure() {
        tabBar.addViewsWithNoTAMIC(borderView)
        borderView.backgroundColor = .gray
        
        NSLayoutConstraint.activate([
            borderView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            borderView.widthAnchor.constraint(equalTo: tabBar.widthAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
