//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 16.06.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
    // Список категорий и вложенных в них трекеров
    private var categories: [TrackerCategory] = [TrackerCategory(name: "Домашний Уют", trackers: [])]
    
    // Список видимых категорий при работы с поиском
    private var visibleCategories: [TrackerCategory] = []
    
    // Трекеры, которые были «выполнены» в выбранную дату
    private var completedTrackers: Set<TrackerRecord> = []
    
    // Параметры для настройки размеров коллекции
    private var params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    // ToDo: - Отображение кнопки "Очистить", которое есть в макетах не настроено. Доделать позже, сейчас просто стандартный крестик
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
        setupCollectionView()
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewTrackerNotification(_:)), name: Notification.Name("NewTrackerNotification"), object: nil)
    }
    
    @objc
    private func handleNewTrackerNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let category = userInfo["Category"] as? TrackerCategory,
               let tracker = userInfo["NewTracker"] as? Tracker {
                if let index = self.categories.firstIndex(where: {$0.name == category.name}) {
                    let oldCategory = self.categories.remove(at: index)
                    let updatedCategory = TrackerCategory(name: category.name, trackers: oldCategory.trackers + [tracker])
                    self.categories.insert(updatedCategory, at: index)
                } else {
                    //            ToDo: - если новая категория прилетает, доработать функционал:
                    //            let newCategory = TrackerCategory(name: categoryName, trackers: [tracker])
                    //            self.categories.append(newCategory)
                }
                DispatchQueue.main.async {
                    self.trackersCollectionView.reloadData()
                }
            }
        }
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
        let destinationViewController = ChooseTrackerTypeViewController()
        destinationViewController.modalPresentationStyle = .formSheet
        present(destinationViewController, animated: true)
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
        [searchTextField, trackersCollectionView].forEach {view.addViewsWithNoTAMIC($0)}
        
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
        trackersCollectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    }
}

// MARK: - UITextFieldDelegate

extension TrackersViewController: UITextFieldDelegate {
    // ToDo: - реализация изменений в коллекции при вводе в поисковую строку
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories[section].trackers.count
        //        visibleCategories.count
        //    ToDo: - Согласно ТЗ чтобы при поиске и/или изменении дня недели отображался другой набор трекеров, рекомендуем параллельно со свойством categories добавить свойство visibleCategories: [TrackerCategory]. Например, это пригодится в случае, когда пользователь вбивает текст в UISearchTextField — содержимое массива categories будет отфильтровываться. При реализации UICollectionViewDataSource нужно использовать visibleCategories. Допускается использовать collectionView.reloadData() после обновления значения visibleCategories (при желании можно использовать collectionView.performBatchUpdates)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        cell.delegate = self
        
        if let category = categories[safe: indexPath.section], category.trackers.indices.contains(indexPath.row) {
            let tracker = category.trackers[indexPath.row]
            cell.trackerTextLabel.text = tracker.name
            cell.emoji.text = tracker.emoji
        } else {
            print("Пусто")
            // ToDo: - Массив trackers пуст или индекс выходит за пределы массива
            // Выполнить альтернативное действие или установите значение по умолчанию
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! SupplementaryView
        view.titleLabel.text = "Домашний уют"
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int((collectionView.bounds.width - params.paddingWidth)) / params.cellCount, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: params.leftInset, bottom: 0, right: params.leftInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
}

extension TrackersViewController: DaysCountProtocol {
    func changeDaysCount(at cell: TrackerCell, isDayCountIncreased: Bool) {
        guard let currentDaysCount = cell.completedDaysLabel.text else { return }
        let currentDaysDigitString = currentDaysCount.filter {$0.isNumber}
        guard let number = Int(currentDaysDigitString) else { return }
        var changedNumber = number
        if isDayCountIncreased {
            changedNumber += 1
        } else {
            changedNumber -= 1
        }
        let formattedLabel = formatDayLabel(for: changedNumber)
        cell.completedDaysLabel.text = formattedLabel
    }
    
    // Для склонения слова "день" в зависимости от числа "1" существует правило: если число заканчивается на "1" и не является числом "11", то используется форма "день"; в остальных случаях используется форма "дня".
    private func formatDayLabel(for number: Int) -> String {
        let lastDigit = number % 10
        let lastTwoDigits = number % 100
        
        if lastDigit == 1 && lastTwoDigits != 11 {
            return "\(number) день"
        } else {
            return "\(number) дней"
        }
    }
}
