//
//  MainTabBarController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 18.06.2023.
//

import UIKit

final class MainTabBarController: UITabBarController {
    private let trackersViewController = TrackersViewController()
    
    private let statisticsModel: StatisticsModel
    private let statisticsViewModel: StatisticsViewModel
    private let statisticsViewController: StatisticsViewController
    
    private let borderView = UIView()
    
    private var trackerNavigationController: UINavigationController!
    
    init() {
        self.statisticsModel = StatisticsModel()
        self.statisticsViewModel = StatisticsViewModel(model: self.statisticsModel)
        self.statisticsViewController = StatisticsViewController(viewModel: self.statisticsViewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
