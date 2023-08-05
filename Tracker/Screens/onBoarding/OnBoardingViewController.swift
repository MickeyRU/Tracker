//
//  OnBoardingViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 28.07.2023.
//

import UIKit

final class OnBoardingViewController: UIViewController {
    private let bgImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    
    init(text: String, bgImage: UIImage) {
        self.textLabel.text = text
        self.bgImageView.image = bgImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        [bgImageView, textLabel].forEach { view.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: view.topAnchor),
            bgImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -16),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
}
