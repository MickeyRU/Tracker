//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 19.06.2023.
//

import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func chosenCategory(name: String)
}

final class CreateTrackerViewController: UIViewController {
    weak var delegate: CreateTrackerViewControllerDelegate?
    
    private let emojiArray = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private let mode: TrackerViewControllerMode
    
    private var trackerOptions: [String] = [] // Опции для отображение в UI, доступные пользователю для выбранного типа трекера (Например расписание или категория)
    private var weekSchedule: [WeekDay] = []
    private var trackerForEditing: Tracker?
    private var selectedEmoji: [Int: String] = [:]
    private var selectedColor: [Int: UIColor] = [:]
    private var categoryValue: String?
    private var isEditingViewController = false
    
    private var colorsArray: [UIColor] = []
    private let createUIHelper = TrackerUIHelper()
    
    private lazy var screenScrollView: UIScrollView = {
        return createUIHelper.createScreenScrollView()
    }()
    
    private lazy var pageTitle: UILabel = {
        return createUIHelper.createPageTitle()
    }()
    
    private lazy var trackerNameTextField: UITextField = {
        let textField = createUIHelper.createTrackerNameTextField()
        textField.delegate = self
        return textField
    }()
    
    private lazy var trackerOptionsTableView: UITableView = {
        return createUIHelper.createTrackerOptionsTableView()
    }()
    
    private lazy var emojiAndColorsCollectionView: UICollectionView = {
        return createUIHelper.createEmojiAndColorsCollectionView()
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = createUIHelper.createCancelButton()
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = createUIHelper.createAcceptButton()
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = createUIHelper.createButtonStackView()
        return stackView
    }()
    
    init(mode: TrackerViewControllerMode) {
        self.mode = mode
        self.colorsArray = ColorsHelper.shared.cellColors
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch mode {
        case .create(let title, let options):
            configContent(title, options, isEdit: true)
            isEditingViewController = false
            
        case .edit(let tracker, let categoryName, let options):
            configContent("Редактирование привычки", options, isEdit: false)
            trackerNameTextField.text = tracker.name
            trackerForEditing = tracker
            categoryValue = categoryName
            weekSchedule = tracker.schedule
            isEditingViewController = true
        }
        
        view.backgroundColor = .white
        setupViews()
        setupTableView()
        setupCollectionView()
        setupButtonStackView()
    }

    private func configContent(_ title: String, _ options: [String], isEdit: Bool) {
        self.pageTitle.text = title
        self.trackerOptions = options
        self.createButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        if isEdit {
            self.createButton.setTitle("Создать", for: .normal)
        } else {
            self.createButton.setTitle("Сохранить", for: .normal)
        }
    }
    
    private func setupViews() {
        view.addViewsWithNoTAMIC(screenScrollView)
        [pageTitle, trackerNameTextField, trackerOptionsTableView, emojiAndColorsCollectionView, buttonStackView].forEach { screenScrollView.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            screenScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            screenScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            screenScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            screenScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            pageTitle.centerXAnchor.constraint(equalTo: screenScrollView.centerXAnchor),
            pageTitle.topAnchor.constraint(equalTo: screenScrollView.topAnchor, constant: 27),
            
            trackerNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            trackerNameTextField.topAnchor.constraint(equalTo: pageTitle.bottomAnchor, constant: 38),
            
            trackerOptionsTableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            trackerOptionsTableView.leadingAnchor.constraint(equalTo: trackerNameTextField.leadingAnchor),
            trackerOptionsTableView.trailingAnchor.constraint(equalTo: trackerNameTextField.trailingAnchor),
            trackerOptionsTableView.heightAnchor.constraint(equalToConstant: CGFloat(trackerOptions.count * 75)),
            
            emojiAndColorsCollectionView.topAnchor.constraint(equalTo: trackerOptionsTableView.bottomAnchor, constant: 32),
            emojiAndColorsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emojiAndColorsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emojiAndColorsCollectionView.heightAnchor.constraint(equalToConstant: 470),
            
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStackView.topAnchor.constraint(equalTo: emojiAndColorsCollectionView.bottomAnchor, constant: 16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTableView() {
        trackerOptionsTableView.dataSource = self
        trackerOptionsTableView.delegate = self
        trackerOptionsTableView.register(TrackerOptionsCell.self, forCellReuseIdentifier: TrackerOptionsCell.reuseIdentifier)
        trackerOptionsTableView.layer.cornerRadius = 16
        trackerOptionsTableView.isScrollEnabled = false
    }
    
    private func setupCollectionView() {
        emojiAndColorsCollectionView.dataSource = self
        emojiAndColorsCollectionView.delegate = self
        emojiAndColorsCollectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        emojiAndColorsCollectionView.register(HeaderViewForEmojiAndColor.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Emoji")
        emojiAndColorsCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)
        emojiAndColorsCollectionView.isScrollEnabled = false
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
    private func doneButtonTapped() {
        let category = TrackerCategory(name: categoryValue ?? "Без категории", trackers: [])
        // ToDo: Функционал по добавлению кастомных категорий
        let trackerName = trackerNameTextField.text ?? ""
        
        var scheduleForNewTracker = [WeekDay]()
        if weekSchedule.count > 0 {
            scheduleForNewTracker = weekSchedule
        } else {
            scheduleForNewTracker = [.monday, .tuesday, .wednesday, .thursday, .friday , .saturday, .sunday] // Для неругярного трекера - доступны все дни недели
        }
        
        var color: UIColor?
        var emoji: String?
        
        if let selectedColorIndex = self.selectedColor.keys.first {
            color = colorsArray[selectedColorIndex]
        }
        
        if let selectedEmojiIndex = self.selectedEmoji.keys.first {
            emoji = emojiArray[selectedEmojiIndex]
        }
        
        let newTracker = Tracker(id: trackerForEditing?.id ?? UUID(),
                                 name: trackerName,
                                 color: color ?? UIColor.randomColor,
                                 emoji: emoji ?? "🔥",
                                 schedule: scheduleForNewTracker,
                                 isPinned: false)
        // Собираем словарь для передачи через нотификацию на главный экран
        let userInfo: [String: Any] = [
            "Category": category,
            "NewTracker": newTracker,
        ]
        
        if !isEditingViewController {
            NotificationCenter.default.post(name: NSNotification.Name("NewTrackerNotification"), object: nil, userInfo: userInfo)
            self.presentingViewController?.presentingViewController?.dismiss(animated: true)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("EditTrackerNotification"), object: nil, userInfo: userInfo)
            self.dismiss(animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension CreateTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trackerOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackerOptionsCell.reuseIdentifier, for: indexPath) as? TrackerOptionsCell else {
            return UITableViewCell()
        }
        let cellName = trackerOptions[indexPath.row]
        let cellAdditionalUIElement = CellElement.arrowImageView
        cell.configCell(nameLabel: cellName, element: cellAdditionalUIElement, indexPath: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.addChoosenOptionTitle(text: categoryValue ?? "")
        case 1:
            cell.addChoosenOptionTitle(text: weekSchedule.shortDaysToString())
        default:
            break
        }
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
            let model = CategoriesModel()
            let viewModel = CategoriesListViewModel(model: model)
            let vc = CategoriesListViewController(viewModel: viewModel)
            self.delegate = vc
            vc.bind()
            vc.delegate = self
            if let value = categoryValue {
                delegate?.chosenCategory(name: value)
            }
            present(vc, animated: true)
        } else {
            // ToDo: реализовать выбор расписания
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            present(scheduleViewController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension CreateTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - ScheduleProtocolDelegate

extension CreateTrackerViewController: ScheduleProtocolDelegate {
    func saveSchedule(weekSchedule: [WeekDay]?) {
        guard let weekSchedule = weekSchedule else { return }
        self.weekSchedule = weekSchedule
        trackerOptionsTableView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension CreateTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseIdentifier, for: indexPath) as? EmojiCell else { return UICollectionViewCell() }
            let emoji = emojiArray[indexPath.row]
            cell.configCell(emoji: emoji)
            if let tracker = trackerForEditing,
               emoji == tracker.emoji {
                cell.didSelectEmoji(isSelected: true)
                selectedEmoji[indexPath.row] = emoji
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseIdentifier, for: indexPath) as? ColorCell else { return UICollectionViewCell() }
            let color = colorsArray[indexPath.row]
            cell.configCell(color: color)
            if let tracker = trackerForEditing,
               color == tracker.color {
                cell.didSelectColor(isSelected: true)
                selectedColor[indexPath.row] = color
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Emoji", for: indexPath) as?
                HeaderViewForEmojiAndColor else { return UICollectionReusableView()}
        
        switch indexPath.section {
        case 0:
            headerView.setupHeaderView(text: "Emoji")
        case 1:
            headerView.setupHeaderView(text: "Цвет")
        default:
            assertionFailure("Свитч вышел в дефолтный")
            break
        }
        return headerView
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 18, bottom: 30, right: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell else { return }
            let emoji = emojiArray[indexPath.row]
            
            // Проверяем, является ли выбранная ячейка уже выбранной
            if selectedEmoji[indexPath.row] != nil {
                // Отменяем выбор
                selectedEmoji.removeValue(forKey: indexPath.row)
                cell.didSelectEmoji(isSelected: false)
            } else {
                // Проверяем, есть ли уже выбранное значение
                if let oldChosenEmojiIndex = selectedEmoji.keys.first {
                    // Удаляем предыдущее выбранное значение
                    selectedEmoji.removeValue(forKey: oldChosenEmojiIndex)
                    
                    // Отменяем выделение у предыдущей ячейки
                    if let oldChosenCell = collectionView.cellForItem(at: IndexPath(row: oldChosenEmojiIndex, section: indexPath.section)) as? EmojiCell {
                        oldChosenCell.didSelectEmoji(isSelected: false)
                    }
                }
                
                // Добавляем новое выбранное значение в словарь
                selectedEmoji[indexPath.row] = emoji
                
                // Выделяем ячейку
                cell.didSelectEmoji(isSelected: true)
            }
        case 1:
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else { return }
            let color = colorsArray[indexPath.row]
            
            if selectedColor[indexPath.row] != nil {
                selectedColor.removeValue(forKey: indexPath.row)
                cell.didSelectColor(isSelected: false)
            } else {
                if let oldChosenColorIndex = selectedColor.keys.first {
                    selectedColor.removeValue(forKey: oldChosenColorIndex)
                    
                    if let oldChosenCell = collectionView.cellForItem(at: IndexPath(row: oldChosenColorIndex, section: indexPath.section)) as? ColorCell {
                        oldChosenCell.didSelectColor(isSelected: false)
                    }
                }
                selectedColor[indexPath.row] = color
                cell.didSelectColor(isSelected: true)
            }
        default:
            print("-------default---------\(indexPath.section)")
        }
    }
}

// MARK: - CategoriesListViewControllerDelegate

extension CreateTrackerViewController: CategoriesListViewControllerDelegate {
    func categoryIsChosen(categoryName: String) {
        categoryValue = categoryName
        trackerOptionsTableView.reloadData()
    }
}
