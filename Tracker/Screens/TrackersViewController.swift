//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 16.06.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
    private let analyticsService = AnalyticsService.shared
    private let dataProvider: DataProviderProtocol
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date
    // Параметры для настройки размеров коллекции
    private var params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)

    private lazy var addButton: UIButton = {
        let button = UIButton.systemButton(with: Images.addTrackerButtonImage ?? UIImage(), target: self, action: #selector(addButtonTapped))
        button.tintColor = UIColor { (traits: UITraitCollection) -> UIColor in
            if traits.userInterfaceStyle == .light {
                return UIColor.black
            } else {
                return UIColor.white
            }
        }
        return button
    }()
    
    private lazy var pageTitle: UILabel = {
        let label = UILabel()
        label.textColor = UIColor { (traits: UITraitCollection) -> UIColor in
            if traits.userInterfaceStyle == .light {
                return UIColor.black
            } else {
                return UIColor.white
            }
        }
        label.text = NSLocalizedString("trackers", comment: "Main Screen title")
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: Date())
        
        var dateComponents = DateComponents()
        dateComponents.year = components.year
        dateComponents.month = components.month
        dateComponents.day = components.day
        datePicker.date = calendar.date(from: dateComponents) ?? Date()
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return datePicker
    }()
    
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
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("filters", comment: "Filter button"), for: .normal)
        button.backgroundColor = UIColor(hex: 0x3772E7)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let placeholderView = PlaceholderView(title: "Что будем отслеживать?",
                                                  image: Images.emptyOnScreenImage ?? UIImage())
    
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
        
        view.backgroundColor = ColorsHelper.shared.viewBackgroundColor
        
        setupCollectionView()
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewTrackerNotification(_:)), name: Notification.Name("NewTrackerNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleEditTrackerNotification(_:)), name: Notification.Name("EditTrackerNotification"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: "open", params: ["screen": "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: "close", params: ["screen": "Main"])
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
    
    private func setupViews() {
        [addButton, datePicker, pageTitle, searchTextField, trackersCollectionView, placeholderView, filterButton].forEach { view.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            addButton.heightAnchor.constraint(equalToConstant: 42),
            addButton.widthAnchor.constraint(equalToConstant: 42),
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            
            pageTitle.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 1),
            pageTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 11),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.widthAnchor.constraint(equalToConstant: 100),
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            
            searchTextField.topAnchor.constraint(equalTo: pageTitle.bottomAnchor, constant: 7),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            trackersCollectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
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
    private func showDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    @objc
    private func filterButtonTapped() {
        analyticsService.report(event: "click", params: [
            "screen": "Main",
            "item": "filter"
        ])
        
        
        let filterViewController = FilterViewController()
        present(filterViewController, animated: true)
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
                        let newCategory = try self.dataProvider.createCategory(category: TrackerCategory(name: category.name, trackers: []))
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
    private func handleEditTrackerNotification (_ notification: Notification) {
        if let userInfo = notification.userInfo {
            // Проверяем что в юзеринфо есть два объекта - категория и трекер
            if let category = userInfo["Category"] as? TrackerCategory,
               let tracker = userInfo["NewTracker"] as? Tracker {
                // Работаем с категорией в кор дате
                var categoryCoreData: TrackerCategoryCoreData?
                if let existedCategory = self.dataProvider.fetchCategory(name: category.name) {
                    categoryCoreData = existedCategory
                } else {
                    do {
                        let newCategory = try self.dataProvider.createCategory(category: TrackerCategory(name: category.name, trackers: []))
                        categoryCoreData = newCategory
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                // Работаем с трекером в кор дате
                guard let categoryCoreData = categoryCoreData else { return }
                var updatedTrackerCoreData: TrackerCoreData?
                
                if let existedTrackerCoreData = self.dataProvider.fetchTracker(id: tracker.id.uuidString) {
                    updatedTrackerCoreData = existedTrackerCoreData
                }
                guard let updatedTrackerCoreData = updatedTrackerCoreData else { return }
                updatedTrackerCoreData.trackerID = tracker.id.uuidString
                updatedTrackerCoreData.name = tracker.name
                updatedTrackerCoreData.colorHex = UIColor.hexString(from: tracker.color)
                updatedTrackerCoreData.emoji = tracker.emoji
                let scheduleString = tracker.schedule.map { $0.numberValue }
                updatedTrackerCoreData.schedule = scheduleString.map(String.init).joined(separator: ", ")
                updatedTrackerCoreData.isPinned = tracker.isPinned
                
                do {
                    try dataProvider.updateTracker(trackerCoreData: updatedTrackerCoreData, trackerCategoryCoreData: categoryCoreData)
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
        analyticsService.report(event: "click", params: [
            "screen": "Main",
            "item": "add_track"
        ])
        
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
            let togglePinAction = UIAction(title: tracker.isPinned ? "Открепить" : "Закрепить") { _ in
                self.togglePin(indexPath: indexPath)
            }
            
            
            let editAction = UIAction(title: "Редактировать") { _ in
                self.analyticsService.report(event: "click", params: [
                    "screen": "Main",
                    "item": "edit"
                ])
                
                let categoryName = self.dataProvider.getTrackerCategoryName(indexPath: indexPath)
                self.editItem(tracker: tracker, categoryName: categoryName)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                self.analyticsService.report(event: "click", params: [
                    "screen": "Main",
                    "item": "delete"
                ])
                
                self.deleteItem(at: indexPath)
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
    
    private func editItem(tracker: Tracker, categoryName: String) {
        let optionsArray = ["Категория", "Расписание"]
        let completedDays = dataProvider.countRecordForTracker(trackerID: tracker.id.uuidString)
        let editViewController = CreateTrackerViewController(mode: .edit(tracker, categoryName, completedDays, optionsArray))
        editViewController.modalPresentationStyle = .formSheet
        present(editViewController, animated: true)
    }
    
    private func deleteItem(at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Уверены, что хотите удалить трекер?", message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            self.deleteTracker(at: indexPath)
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func deleteTracker(at indexPath: IndexPath) {
        let trackerCoreData = dataProvider.getTrackerCoreData(indexPath: indexPath)
        do {
            try dataProvider.deleteTracker(trackerCoreData: trackerCoreData)
        } catch {
            print(error.localizedDescription)
        }
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
        reloadData(searchText: searchTextField.text)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        reloadData(searchText: newText)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        reloadData(searchText: "")
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
