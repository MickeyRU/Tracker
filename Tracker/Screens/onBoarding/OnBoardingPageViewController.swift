//
//  OnBoardingPageViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 28.07.2023.
//

import UIKit

final class OnBoardingPageViewController: UIPageViewController {
    var confirmedByUser: (() -> Void)?
    
    private lazy var pages: [UIViewController] = {
        let blueViewController = OnBoardingViewController(text: "Отслеживайте только то, что хотите", bgImage: Images.onBoardingBlueImage ?? UIImage())
        let redViewController = OnBoardingViewController(text: "Даже если это не литры воды и йога", bgImage: Images.onBoardingRedImage ?? UIImage())
        return [blueViewController, redViewController]
    }()
    
   private lazy var pageControl: UIPageControl = {
       let pageControl = UIPageControl()
       pageControl.numberOfPages = self.pages.count
       pageControl.currentPage = 0
       pageControl.currentPageIndicatorTintColor = .black
       pageControl.pageIndicatorTintColor = .gray
       return pageControl
    }()
    
    private lazy var onboardingFinishButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let firstScreen = pages.first {
            setViewControllers([firstScreen], direction: .forward, animated: true)
        }
        
        setupViews()
    }
    
    @objc private func finishButtonTapped() {
        confirmedByUser?()
    }
    
    private func setupViews() {
        [pageControl, onboardingFinishButton].forEach { view.addViewsWithNoTAMIC($0) }

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: onboardingFinishButton.topAnchor, constant: -24),
            
            onboardingFinishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            onboardingFinishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            onboardingFinishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            onboardingFinishButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnBoardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate
    
extension OnBoardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            let currentViewController = pageViewController.viewControllers?.first,
            let currentIndex = pages.firstIndex(of: currentViewController)
        else { return }
        
        pageControl.currentPage = currentIndex
    }
}
