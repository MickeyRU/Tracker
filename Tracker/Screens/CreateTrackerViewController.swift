//
//  TrackerDetailsViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 19.06.2023.
//

import UIKit

final class CreateTrackerViewController: UIViewController {
    private var trackerOptions: [String] = [] // Опции для отображение в UI, доступные пользователю для выбранного типа трекера (Например расписание)
    private var weekSchedule = WeekSchedule() // Экземпляр модели дни недели для хранения расписания в случае если трекер - привычка
    
    private var pageTitle: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private let trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(red: 0.9, green: 0.91, blue: 0.92, alpha: 0.3)
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 16
        
        // Создаем отступ, для текста в плейсхолдере
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    private let trackerOptionsTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(red: 0.96, green: 0.42, blue: 0.42, alpha: 1.0), for: .normal)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = CGColor(red: 0.96, green: 0.42, blue: 0.42, alpha: 1.0)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupViews()
        setupTableView()
        setupButtonStackView()
    }
    
    func configTitleAndOptions(_ title: String, _ options: [String]) {
        self.pageTitle.text = title
        self.trackerOptions = options
    }
        
    private func setupViews() {
        [pageTitle, trackerNameTextField, trackerOptionsTableView, buttonStackView].forEach { view.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            pageTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            trackerNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            trackerNameTextField.topAnchor.constraint(equalTo: pageTitle.bottomAnchor, constant: 38),
            
            trackerOptionsTableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            trackerOptionsTableView.leadingAnchor.constraint(equalTo: trackerNameTextField.leadingAnchor),
            trackerOptionsTableView.trailingAnchor.constraint(equalTo: trackerNameTextField.trailingAnchor),
            trackerOptionsTableView.heightAnchor.constraint(equalToConstant: CGFloat(trackerOptions.count * 75)),
            
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTableView() {
        trackerOptionsTableView.dataSource = self
        trackerOptionsTableView.delegate = self
        trackerOptionsTableView.register(CreateTrackerCell.self, forCellReuseIdentifier: CreateTrackerCell.reuseIdentifier)
        trackerOptionsTableView.layer.cornerRadius = 16
    }
    
    private func setupButtonStackView() {
        [cancelButton, createButton].forEach { buttonStackView.addArrangedSubview($0) }
        buttonStackView.spacing = 8
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
    }
    
    @objc
    private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc
    private func createButtonTapped() {
        // При нажатии на кнопку у нас создается категория выбранная пользователем и трекер
        // ToDo: доработать функционал позже, пока статичная категория
        let category = TrackerCategory(name: "Учимся кодить", trackers: [])
        
        // ToDo: - Добавить функционал нейминга нового трекера в соотвествии с тем, что ввел пользователь в текстфилде.
        let trackerName = "Тестовый трекер"
        
        let newTracker = Tracker(name: trackerName,
                                 color: UIColor.randomColor, // ToDo: - Пока рандом - дальше переделать на выбранное пользователем.
                                 emoji: "🔥", // ToDo: - Пока сам указал - дальше переделать на выбранное пользователем.
                                 schedule: weekSchedule)
        // Собираем словарь для передачи через нотификацию на главный экран
        let userInfo: [String: Any] = [
            "Category": category,
            "NewTracker": newTracker,
        ]
        
        NotificationCenter.default.post(name: NSNotification.Name("NewTrackerNotification"), object: nil, userInfo: userInfo)
        self.presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CreateTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trackerOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CreateTrackerCell.reuseIdentifier, for: indexPath) as? CreateTrackerCell else {
            return UITableViewCell()
        }
        let cellName = trackerOptions[indexPath.row]
        let cellAdditionalUIElement = CellElement.arrowImageView
        cell.configCell(nameLabel: cellName, element: cellAdditionalUIElement)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CreateTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        SeparatorLineHelper.configSeparatingLine(tableView: tableView, cell: cell, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // ToDo: реализовать выбор категории
            print("Нажали кнопку категория")
        } else { 
            // ToDo: реализовать выбор расписания
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            present(scheduleViewController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension CreateTrackerViewController: ScheduleProtocol {
    func updateSchedule(weekSchedule: WeekSchedule) {
        self.weekSchedule = weekSchedule
    }
}
