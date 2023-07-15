//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 16.06.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
    private var dataProvider: DataProviderProtocol
    
    // Категории для работы с логикой добавления / удаления трекеров
    private var categories: [TrackerCategory] = []
    // Категории для отображения в UI
    private var visibleCategories: [TrackerCategory] = []
    // Выполненные трекеры
    private var completedTrackers: [TrackerRecord] = []
    // Текущая дата
    private var currentDate: Date
    // Параметры для настройки размеров коллекции
    private var params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    private let dataManager = DataManager.shared
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return datePicker
    }()
    
    // ToDo: - Отображение кнопки "Очистить", которое есть в макетах не настроено. Доделать позже, сейчас просто стандартный крестик
    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.placeholder = "Поиск"
        textField.delegate = self
        return textField
    }()
    
    private let trackersCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        return collectionView
    }()
    
    private let placeholderView = PlaceholderView(
        title: "Что будем отслеживать?"
    )
    
    
    init() {
        self.dataProvider = DataProvider(trackerStore: TrackerStore(),
                                         trackerCategoryStore: TrackerCategoryStore(),
                                         trackerRecordsStore: TrackerRecordStore())
        self.currentDate = Date()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadData()
        
        currentDate = Date()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupCollectionView()
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewTrackerNotification(_:)), name: Notification.Name("NewTrackerNotification"), object: nil)
    }
    
    private func reloadCurrentDate() {
        self.currentDate = datePicker.date
    }
    
    private func reloadData() {
        categories = dataManager.categories
        dateChanged()
    }
    
    private func setupNavigationBar() {
        // Установка заголовка
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Трекеры"
        
        // Создание UIBarButtonItem с кнопкой "+"
        let addButton = UIBarButtonItem(image: Images.addTrackerButtonImage, style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .black
        navigationItem.leftBarButtonItem = addButton
        
        // Создание UIBarButtonItem с UIDatePicker в качестве кастомного представления
        let datePickerBarButton = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerBarButton
        
    }
    
    private func setupViews() {
        [searchTextField, trackersCollectionView, placeholderView].forEach { view.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            trackersCollectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            placeholderView.centerXAnchor.constraint(equalTo: trackersCollectionView.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: trackersCollectionView.centerYAnchor)
        ])
    }
    
    private func setupCollectionView() {
        trackersCollectionView.delegate = self
        trackersCollectionView.dataSource = self
        
        trackersCollectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        trackersCollectionView.register(HeaderMainScreenView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    }
    
    private func reloadVisibleCategories(text: String?, date: Date) {
        let calendar = Calendar.current
        let filterWeekDay = calendar.component(.weekday, from: date)
        let filterText = (text ?? "").lowercased()
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty ||
                tracker.name.lowercased().contains(filterText)
                let dateCondition = tracker.schedule.contains { weekDay in
                    weekDay.numberValue == filterWeekDay
                } == true
                return textCondition && dateCondition
            }
            
            if trackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(
                name: category.name,
                trackers: trackers
            )
        }
        
        trackersCollectionView.reloadData()
        reloadPlaceholder()
    }
    
    private func reloadPlaceholder() {
        placeholderView.isHidden = !visibleCategories.isEmpty
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: currentDate)
        return trackerRecord.trackerID == id && isSameDay

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
                reloadCurrentDate()
                reloadVisibleCategories(text: searchTextField.text, date: currentDate)
            }
        }
    }
    
    @objc
    private func dateChanged() {
        reloadCurrentDate()
        reloadVisibleCategories(text: searchTextField.text, date: currentDate)
    }
    
    @objc
    private func addButtonTapped() {
        // Действия при нажатии кнопки "+"
        let destinationViewController = ChooseTrackerTypeViewController()
        destinationViewController.modalPresentationStyle = .formSheet
        present(destinationViewController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let trackers = visibleCategories[section].trackers
        return trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        cell.delegate = self
        
        let cellData = visibleCategories
        let tracker = cellData[indexPath.section].trackers[indexPath.row]
        
        cell.delegate = self
        
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter { $0.trackerID == tracker.id }.count
        cell.configCell(
            tracker: tracker,
            isCompletedToday: isCompletedToday,
            indexPath: indexPath,
            completedDays: completedDays
        )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! HeaderMainScreenView
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

extension TrackersViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let realDate = Date()
        if realDate < currentDate {
            print("Попытка изменить количество выполнений трекера в будущей дате")
        } else {
            let trackerRecord = TrackerRecord(trackerID: id, date: datePicker.date)
            completedTrackers.append(trackerRecord)
            
            trackersCollectionView.reloadItems(at: [indexPath])
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        let realDate = Date()
        if realDate < currentDate {
            print("Попытка изменить количество выполнений трекера в будущей дате")
        } else {
            completedTrackers.removeAll { trackerRecord in
                isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
            }
            
            trackersCollectionView.reloadItems(at: [indexPath])
        }
    }
}

// MARK: - UITextFieldDelegate

extension TrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        reloadCurrentDate()
        reloadVisibleCategories(text: textField.text, date: currentDate)
        return true
    }
}
