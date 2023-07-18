//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 19.06.2023.
//

import UIKit

final class CreateTrackerViewController: UIViewController {
    private var trackerOptions: [String] = [] // Опции для отображение в UI, доступные пользователю для выбранного типа трекера (Например расписание)
    
    private var weekSchedule = [WeekDay]()
    
    private let emojiArray = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private let colorsArray = ColorsHelper.shared.GenerateColors()
    
    private var selectedEmoji: [Int: String] = [:]
    private var selectedColor: [Int: UIColor] = [:]
    
    private let screenScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 920)
        return scrollView
    }()
    
    private var pageTitle: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(red: 0.9, green: 0.91, blue: 0.92, alpha: 0.3)
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 16
        textField.delegate = self
        
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
    
    private let emojiAndColorsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        return collectionView
    }()
    
    private lazy var cancelButton: UIButton = {
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
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
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
        setupCollectionView()
        setupButtonStackView()
    }
    
    func configTitleAndOptions(_ title: String, _ options: [String]) {
        self.pageTitle.text = title
        self.trackerOptions = options
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
        trackerOptionsTableView.register(CreateTrackerCell.self, forCellReuseIdentifier: CreateTrackerCell.reuseIdentifier)
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
    private func createButtonTapped() {
        let category = TrackerCategory(name: "Создаем новые категории", trackers: [])
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
        
        let newTracker = Tracker(id: UUID(),
                                 name: trackerName,
                                 color: color ?? UIColor.randomColor,
                                 emoji: emoji ?? "🔥",
                                 schedule: scheduleForNewTracker)
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
        cell.configCell(nameLabel: cellName, element: cellAdditionalUIElement, indexPath: indexPath)
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
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseIdentifier, for: indexPath) as? ColorCell else { return UICollectionViewCell() }
            let color = colorsArray[indexPath.row]
            cell.configCell(color: color)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Emoji", for: indexPath) as! HeaderViewForEmojiAndColor
        switch indexPath.section {
        case 0:
            headerView.titleLabel.text = "Emoji"
        case 1:
            headerView.titleLabel.text = "Цвет"
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
                cell.emojiIsSelected(isSelected: false)
            } else {
                // Проверяем, есть ли уже выбранное значение
                if let oldChosenEmojiIndex = selectedEmoji.keys.first {
                    // Удаляем предыдущее выбранное значение
                    selectedEmoji.removeValue(forKey: oldChosenEmojiIndex)
                    
                    // Отменяем выделение у предыдущей ячейки
                    if let oldChosenCell = collectionView.cellForItem(at: IndexPath(row: oldChosenEmojiIndex, section: indexPath.section)) as? EmojiCell {
                        oldChosenCell.emojiIsSelected(isSelected: false)
                    }
                }
                
                // Добавляем новое выбранное значение в словарь
                selectedEmoji[indexPath.row] = emoji
                
                // Выделяем ячейку
                cell.emojiIsSelected(isSelected: true)
            }
        case 1:
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else { return }
            let color = colorsArray[indexPath.row]
            
            if selectedColor[indexPath.row] != nil {
                selectedColor.removeValue(forKey: indexPath.row)
                cell.colorIsSelected(isSelected: false)
            } else {
                if let oldChosenColorIndex = selectedColor.keys.first {
                    selectedColor.removeValue(forKey: oldChosenColorIndex)
                    
                    if let oldChosenCell = collectionView.cellForItem(at: IndexPath(row: oldChosenColorIndex, section: indexPath.section)) as? ColorCell {
                        oldChosenCell.colorIsSelected(isSelected: false)
                    }
                }
                
                selectedColor[indexPath.row] = color
                
                cell.colorIsSelected(isSelected: true)
            }
        default:
            print("-------default---------\(indexPath.section)")
        }
    }
}
