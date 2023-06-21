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
    
    // Список видимых категорий с учетом текущей даты в пикере.
    private var visibleTrackersCategoryForDay = [TrackerCategory]()
    
    private var visibleTrackersCategoriesAfterFilter = [TrackerCategory]()
    
    private var isFiltered: Bool  {
        let searchText = searchTextField.text ?? ""
        return !searchText.isEmpty
    }
    
    
    // Трекеры, которые были «выполнены» в выбранную дату
    private var completedTrackers: Set<TrackerRecord> = []
    
    // Параметры для настройки размеров коллекции
    private var params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(showTrackersOnDate), for: .valueChanged)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupCollectionView()
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewTrackerNotification(_:)), name: Notification.Name("NewTrackerNotification"), object: nil)
    }
    
    @objc
    private func showTrackersOnDate() {
        // Получаем выбранную дату из UIDatePicker
        let selectedDate = datePicker.date
        
        // Фильтрация трекеров на основе выбранного дня недели
        filterTrackersForSelectedDayOfWeek(selectedDate)
    }
    
    @objc
    private func searchTextFieldValueChanged() {
        // Получаем текст из UISearchTextField
        let searchText = searchTextField.text ?? ""
        
        // Фильтрация трекеров на основе введенного текста
        filterTrackersBySearchText(searchText)
    }
    
    
    private func filterTrackersForSelectedDayOfWeek(_ selectedDate: Date) {
        // Получаем день недели для выбранной даты
        let selectedDayOfWeek = Calendar.current.component(.weekday, from: selectedDate) - 1
        // Фильтруем трекеры по выбранному дню недели
        let filteredTrackers = categories.flatMap { $0.trackers.filter { $0.schedule.daysOfWeek[selectedDayOfWeek - 1].isSelected } }
        // Обновляем видимые категории трекеров
        visibleTrackersCategoryForDay = createVisibleCategories(from: filteredTrackers)
        
        // Обновляем коллекцию для отображения трекеров
        trackersCollectionView.reloadData()
    }
    
    private func filterTrackersBySearchText(_ searchText: String) {
        // Фильтруем трекеры по введенному тексту
        let filteredTrackers = categories.flatMap { $0.trackers.filter { $0.name.lowercased().contains(searchText.lowercased()) } }
        
        // Обновляем видимые категории трекеров
        visibleTrackersCategoriesAfterFilter = createVisibleCategories(from: filteredTrackers)
        
        // Обновляем коллекцию для отображения трекеров
        trackersCollectionView.reloadData()
    }
    
    private func createVisibleCategories(from trackers: [Tracker]) -> [TrackerCategory] {
        var categoriesDict: [String: [Tracker]] = [:]
        
        // Группируем трекеры по имени категории в словаре
        for tracker in trackers {
            let categoryName = tracker.name
            if var trackersArray = categoriesDict[categoryName] {
                trackersArray.append(tracker)
                categoriesDict[categoryName] = trackersArray
            } else {
                categoriesDict[categoryName] = [tracker]
            }
        }
        
        // Создаем массив видимых категорий на основе значений словаря
        let visibleCategories = categoriesDict.map { TrackerCategory(name: $0.key, trackers: $0.value) }
        
        return visibleCategories
    }
    
    
    @objc
    private func handleNewTrackerNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
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
                
                if isFiltered {
                    let TrackersCategoriesArrayForUpdate = visibleTrackersCategoriesAfterFilter
                    DispatchQueue.main.async {
                        self.trackersCollectionView.reloadData()
                    }
                } else {
                    let TrackersCategoriesArrayForUpdate = visibleTrackersCategoryForDay
                    let selectedDate = datePicker.date
                    filterTrackersForSelectedDayOfWeek(selectedDate)
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

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        isFiltered ? visibleTrackersCategoriesAfterFilter.count : visibleTrackersCategoryForDay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let trackersCategoriesArray = isFiltered ? visibleTrackersCategoriesAfterFilter : visibleTrackersCategoryForDay
        let category = trackersCategoriesArray[section]
        return category.trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        cell.delegate = self
        
        let trackersCategoriesArray = isFiltered ? visibleTrackersCategoriesAfterFilter : visibleTrackersCategoryForDay
        let tracker = trackersCategoriesArray[indexPath.section].trackers[indexPath.row]
        cell.emoji.text = tracker.emoji
        cell.trackerTextLabel.text = tracker.name
        cell.backGroundViewColor.backgroundColor = tracker.color
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! SupplementaryView
        let trackersCategoriesArray = isFiltered ? visibleTrackersCategoriesAfterFilter : visibleTrackersCategoryForDay
        let category = trackersCategoriesArray[indexPath.section]
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
