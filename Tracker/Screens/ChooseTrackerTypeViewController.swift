//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 18.06.2023.
//

import UIKit

final class ChooseTrackerTypeViewController: UIViewController {
    private let pageTitle: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private lazy var habitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(habitButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Нерегулярные события", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(irregularEvenButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupViews()
    }
    
    private func presentCreateViewController(trackerName: String, category: [String]) {
        let createTrackerViewController = CreateTrackerViewController()
        createTrackerViewController.modalPresentationStyle = .formSheet
        let optionsArray = category
        createTrackerViewController.configTitleAndOptions(trackerName, optionsArray)
        present(createTrackerViewController, animated: true)
    }

    private func setupViews() {
        [pageTitle, habitButton, irregularEventButton].forEach { view.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            pageTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.leadingAnchor.constraint(equalTo: habitButton.leadingAnchor),
            irregularEventButton.trailingAnchor.constraint(equalTo: habitButton.trailingAnchor),
            irregularEventButton.heightAnchor.constraint(equalTo: habitButton.heightAnchor)
        ])
    }
    
    @objc
    private func habitButtonDidTapped() {
        presentCreateViewController(trackerName: "Новая привычка", category: ["Категория", "Расписание"])
    }
    
    @objc
    private func irregularEvenButtonDidTapped() {
        presentCreateViewController(trackerName: "Новое нерегулярное событие", category: ["Категория"])
    }
}
