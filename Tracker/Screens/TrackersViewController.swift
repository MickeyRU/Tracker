//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 16.06.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
    // Список категорий и вложенных в них трекеров
    private var categories = [TrackerCategory]()
    
    // Список категорий для отображения в UI
    private var visibleCategories = [TrackerCategory]()
    
    // Трекеры, которые были «выполнены» в выбранную дату
    private var completedTrackers: Set<TrackerRecord> = []
    
    // Текущая дата
    private var currentDate: Date
    
    // Параметры для настройки размеров коллекции
    private var params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(sortTrackersByChosenDayOfWeek), for: .valueChanged)
        return datePicker
    }()
    
    // ToDo: - Отображение кнопки "Очистить", которое есть в макетах не настроено. Доделать позже, сейчас просто стандартный крестик
    private let searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.placeholder = "Поиск"
        textField.addTarget(self, action: #selector(searchTextFieldValueChanged), for: .editingChanged)
        return textField
    }()
    
    private let trackersCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        return collectionView
    }()
    
    init() {
        self.currentDate = Date()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentDate = Date()
        
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupCollectionView()
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewTrackerNotification(_:)), name: Notification.Name("NewTrackerNotification"), object: nil)
    }
    
    @objc
    private func sortTrackersByChosenDayOfWeek() {
        sortTrackersForChosenDay()
    }
    
    private func sortTrackersForChosenDay() {
        // Обновляем текущую дату на дату выбранную в пикере.
        currentDate = datePicker.date
        
        // Получаем числовое значение текущего дня недели - Понедельник это 0, воскресенье 6
        let weekDay = getCurrentDaysOfWeekNumber()
        
        // Фильтруем массив categories и находим все трекеры с разбивкой по категория и возвращаем обновленный массив категорий.
        let matchingCategories = categories.map { category -> TrackerCategory in
            let selectedTrackers = category.trackers.filter { tracker in
                return tracker.schedule.daysOfWeek[weekDay].isSelected
            }
            return TrackerCategory(name: category.name, trackers: selectedTrackers)
        }

    // Обновляем видимые категории трекеров для отображения в UI
    visibleCategories = matchingCategories
    // Обновляем коллекцию для отображения трекеров
    trackersCollectionView.reloadData()
}

@objc
private func searchTextFieldValueChanged() {
    // Получаем текст из UISearchTextField
    let searchText = searchTextField.text ?? ""
    
    // Фильтрация трекеров на основе введенного текста
    filterTrackersBySearchText(searchText)
}

private func filterTrackersBySearchText(_ searchText: String) {
    
}

private func getCurrentDaysOfWeekNumber() -> Int {
    // Получаем день недели для текущей даты
    var weekDay = Calendar.current.component(.weekday, from: currentDate) - 1
    
    // Если значение weekday равно 0 (воскресенье), изменяем его на 6 (суббота)
    if weekDay == 0 {
        weekDay = 6
    } else {
        weekDay -= 1
    }
    return weekDay
}

@objc
private func handleNewTrackerNotification(_ notification: Notification) {
    if let userInfo = notification.userInfo {
        // Проверяем что в юзеринфо есть два объекта - категория и трекер
        if let category = userInfo["Category"] as? TrackerCategory,
           let tracker = userInfo["NewTracker"] as? Tracker {
            // Если категория уже существует в главное хранилище трекеров "categories", то обновляем
            if let index = self.categories.firstIndex(where: {$0.name == category.name}) {
                let oldCategory = self.categories.remove(at: index)
                let oldTrackersArray = oldCategory.trackers
                
                // Создаем новый массив трекеров, добавляя новый трекер
                var updatedTrackersArray = oldTrackersArray
                updatedTrackersArray.append(tracker)
                
                // Создаем новый экземпляр TrackerCategory с обновленным списком трекеров
                let updatedCategory = TrackerCategory(name: oldCategory.name, trackers: updatedTrackersArray)
                
                self.categories.insert(updatedCategory, at: index)
                
            } else {
                let newCategory = TrackerCategory(name: category.name, trackers: [tracker])
                self.categories.append(newCategory)
            }
            
            // Получаем числовое значение текущего дня недели - Понедельник это 0, воскресенье 6
            let weekDay = getCurrentDaysOfWeekNumber()
            if tracker.schedule.daysOfWeek[weekDay].isSelected {
                self.trackersCollectionView.reloadData()
            } else {
                print("Трекер создан на день отличный от текущего ")
            }
            self.visibleCategories = self.categories
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

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = visibleCategories[section]
        return category.trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        cell.delegate = self
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        cell.emoji.text = tracker.emoji
        cell.trackerTextLabel.text = tracker.name
        cell.backGroundViewColor.backgroundColor = tracker.color
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! SupplementaryView
        let category = visibleCategories[indexPath.section]
        headerView.titleLabel.text = category.name
        return headerView
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

// MARK: - DaysCountProtocol

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
