//
//  ViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 16.06.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    private let searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.placeholder = "Поиск"
        return textField
    }()
    
    private let trackersCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    
        setupNavigationBar()
        setupViews()
        setupCollectionView()
    }
    
    private func setupNavigationBar() {
        // Установка заголовка
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Трекеры"
        
        // Создание UIBarButtonItem с кнопкой "+"
        let addButton = UIBarButtonItem(image: Images.addButtonImage, style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .black
        navigationItem.leftBarButtonItem = addButton
        
        // Создание UIBarButtonItem с UIDatePicker в качестве кастомного представления
        let datePickerBarButton = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerBarButton
    
    }
    
    @objc
    private func addButtonTapped() {
        // Действия при нажатии кнопки "+"
        // ToDo: - При нажатии на неё отображается экран выбора типа трекера («Привычка» или «Нерегулярное событие») — см. пункт 7 ниже
    }
    
    @objc
    private func datePickerValueChanged() {
        let selectedDate = datePicker.date
        // Обновление отображаемых трекеров привычек на основе выбранной даты
        updateTrackersForSelectedDate(selectedDate)
    }
    
    private func updateTrackersForSelectedDate(_ date: Date) {
        // Обновление отображаемых трекеров привычек на основе выбранной даты
        // ToDo: - При изменении даты отображаются трекеры привычек, которые должны быть видны в день недели, выбранный в UIDatePicker
    }
    
    private func setupViews() {
        [searchTextField, trackersCollectionView].forEach {view.addViewsWithTAMIC($0)}
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            trackersCollectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupCollectionView() {
        trackersCollectionView.delegate = self
        trackersCollectionView.dataSource = self
        
        trackersCollectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
    }
}

// MARK: - UITextFieldDelegate

extension TrackersViewController: UITextFieldDelegate {
    // ToDo: - реализация изменений в коллекции при вводе в поисковую строку
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else {return UICollectionViewCell()}
        return cell
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 167, height: 148)
    }
}
