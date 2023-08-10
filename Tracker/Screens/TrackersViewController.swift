//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 16.06.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
    private let dataProvider: DataProviderProtocol
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date
    // Параметры для настройки размеров коллекции
    private var params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    
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
        dataProvider = DataProvider(trackerStore: TrackerStore(),
                                    trackerRecordsStore: TrackerRecordStore(delegate: nil),
                                    trackerCategoryStore: TrackerCategoryStore(),
                                    delegate: nil)
        self.currentDate = Date()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataProvider.setUpDelegates(trackersViewController: self)
        
        updateDate()
        reloadData(searchText: nil)
        
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupCollectionView()
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewTrackerNotification(_:)), name: Notification.Name("NewTrackerNotification"), object: nil)
    }
    
    private func updateDate() {
        self.currentDate = datePicker.date
    }
    
    private func reloadData(searchText: String?) {
        do {
            try dataProvider.addFiltersForFetchResultController(searchText: searchText ?? "", date: currentDate)
        } catch {
            print(error.localizedDescription)
        }
        trackersCollectionView.reloadData()
        reloadPlaceholder()
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
    
    private func reloadPlaceholder() {
        if dataProvider.numberOfTrackers == 0 {
            placeholderView.isHidden = false
        } else {
            placeholderView.isHidden = true
        }
    }
    
    private func getDayWithZeroedTime(date: Date) -> Date {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        guard let dayWithZeroedTime = Calendar.current.date(from: dateComponents) else { return Date() }
        return dayWithZeroedTime
    }
    
    @objc
    private func handleNewTrackerNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            // Проверяем что в юзеринфо есть два объекта - категория и трекер
            if let category = userInfo["Category"] as? TrackerCategory,
               let tracker = userInfo["NewTracker"] as? Tracker {
                // Работаем с категорией в кор дате
                var categoryCoreData: TrackerCategoryCoreData?
                if let existingCategory = self.dataProvider.fetchCategory(name: category.name) {
                    categoryCoreData = existingCategory
                } else {
                    do {
                        let newCategory = try self.dataProvider.createCategory(category: TrackerCategory(name: category.name,
                                                                                                         trackers: []))
                        categoryCoreData = newCategory
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                // Работаем с трекером в кор дате - по аналогии с категорией
                guard let categoryCoreData = categoryCoreData else { return }
                do {
                    try self.dataProvider.addTracker(tracker: tracker, trackerCategoryCoreData: categoryCoreData)
                } catch {
                    print(error.localizedDescription)
                }
            }
            reloadData(searchText: searchTextField.text)
        }
    }
    
    @objc
    private func dateChanged() {
        updateDate()
        reloadData(searchText: searchTextField.text)
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
        dataProvider.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataProvider.numberOfRowsInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        cell.delegate = self
        
        guard let tracker = dataProvider.getTrackerObject(indexPath: indexPath) else { return UICollectionViewCell() }
        
        let isCompletedToday = dataProvider.trackerTrackedToday(date: getDayWithZeroedTime(date: currentDate), trackerID: tracker.id.uuidString)
        let completedDays = dataProvider.countRecordForTracker(trackerID: tracker.id.uuidString)
        
        cell.configCell(
            tracker: tracker,
            isCompletedToday: isCompletedToday,
            indexPath: indexPath,
            completedDays: completedDays
        )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as? HeaderMainScreenView else { return UICollectionReusableView() }
        let sectionName = dataProvider.nameOfSection(section: indexPath.section)
        headerView.titleLabel.text = sectionName
        return headerView
    }
}

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        configurateContextMenu(indexPath: indexPath)
    }
    
    private func configurateContextMenu(indexPath: IndexPath) -> UIContextMenuConfiguration {
        let identifier = "\(indexPath)" as NSString
        guard let tracker = self.dataProvider.getTrackerObject(indexPath: indexPath) else { return UIContextMenuConfiguration() }

        
        return UIContextMenuConfiguration(identifier: identifier,
                                          previewProvider: { [weak self] in
            guard let self = self else { return UIViewController() }
            let previewVC = EditingPreviewViewController()
            let cellSize = CGSize(width: Int((trackersCollectionView.bounds.width - self.params.paddingWidth)) / params.cellCount, height: 88)
            previewVC.configureView(sizeForPreview: cellSize, tracker: tracker)
            return previewVC
        },
                                          actionProvider: { [weak self] _ in
            guard let self = self else { return UIMenu() }
            let togglePinAction = UIAction(title: tracker.isPinned ? "Открепить" : "Закрепить") { [weak self] _ in
                guard let self = self else { return }
                self.togglePin(indexPath: indexPath)
            }
            
            
            let editAction = UIAction(title: "Редактировать") { _ in
                self.editItem(at: indexPath.row)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                self.deleteItem(at: indexPath.row)
            }
            
            return UIMenu(title: "", children: [togglePinAction, editAction, deleteAction])
        })
    }
    
    private func isTrackerPinned(at indexPath: IndexPath) -> Bool {
        guard let isPinned = dataProvider.getTrackerObject(indexPath: indexPath)?.isPinned else { return false }
        return isPinned
    }
    
    private func togglePin(indexPath: IndexPath) {
        do {
            try dataProvider.togglePinForTracker(indexPath: indexPath)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func editItem(at index: Int) {
        // Ваша логика для редактирования элемента
    }
    
    private func deleteItem(at index: Int) {
        // Ваша логика для удаления элемента
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

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let realDate = Date()
        if realDate < currentDate {
            print("Попытка изменить количество выполнений трекера в будущей дате")
        } else {
            let trackerRecord = TrackerRecord(trackerID: id, date: getDayWithZeroedTime(date: currentDate))
            let trackerCoreData = dataProvider.getTrackerCoreData(indexPath: indexPath)
            do {
                try dataProvider.addNewTrackerRecord(trackerRecord: trackerRecord, trackerCoreData: trackerCoreData)
            } catch {
                print(error.localizedDescription)
            }
            trackersCollectionView.reloadItems(at: [indexPath])
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        let realDate = Date()
        if realDate < currentDate {
            print("Попытка изменить количество выполнений трекера в будущей дате")
        } else {
            do {
                try dataProvider.deleteRecord(date: getDayWithZeroedTime(date: currentDate), trackerID: id.uuidString)
            } catch {
                print(error.localizedDescription)
            }
        }
        trackersCollectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - UITextFieldDelegate

extension TrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        updateDate()
        reloadData(searchText: searchTextField.text)
        return true
    }
}

// MARK: - DataProviderDelegate

extension TrackersViewController: DataProviderDelegate {
    func didChangeContent() {
        trackersCollectionView.reloadData()
    }
}

// MARK: - TrackerRecordStoreDelegate

extension TrackersViewController: TrackerRecordStoreDelegate {
    func didUpdateRecords(completedTrackers: [TrackerRecord]) {
        self.completedTrackers = completedTrackers
    }
}
