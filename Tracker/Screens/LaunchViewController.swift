//
//  LaunchViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 28.07.2023.
//

import UIKit

final class LaunchViewController: UIViewController {
    @UserDefaultsBacked<Bool>(key: "is_onboarding_completed") private var isOnboardingCompleted
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkOnBoardingStatus()
    }
    
    private func checkOnBoardingStatus() {
        let mainTabBarController = MainTabBarController()

        guard isOnboardingCompleted != nil else {
            let onBoardingPageViewController = OnBoardingPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            
            onBoardingPageViewController.confirmedByUser = { [weak self] in
                guard let self = self else { return }
                
                self.isOnboardingCompleted = true
                self.removeViewController(chieldViewController: onBoardingPageViewController)
                self.addViewController(chieldViewController: mainTabBarController)
            }
            addViewController(chieldViewController: onBoardingPageViewController)
            return
        }
        addViewController(chieldViewController: mainTabBarController)
    }
    
    private func addViewController(chieldViewController: UIViewController) {
        if let chieldView = chieldViewController.view,
           let parentView = view {
            addChild(chieldViewController)
            parentView.addViewsWithNoTAMIC(chieldView)
            
            NSLayoutConstraint.activate([
                chieldView.topAnchor.constraint(equalTo: parentView.topAnchor),
                chieldView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                chieldView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
                chieldView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
            ])
        }
        chieldViewController.didMove(toParent: self)
    }
    
    private func removeViewController(chieldViewController: UIViewController) {
        chieldViewController.willMove(toParent: nil)
        chieldViewController.view.removeFromSuperview()
        chieldViewController.removeFromParent()
    }
}
