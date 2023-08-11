//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 20.06.2023.
//

import UIKit

protocol ScheduleProtocolDelegate: AnyObject {
    func saveSchedule(weekSchedule: [WeekDay]?)
}

final class ScheduleViewController: UIViewController {
    weak var delegate: ScheduleProtocolDelegate?
    
    private let weekDays = WeekDay.allCases
    private var weekSchedule: [WeekDay] = []
    
    private var pageTitle: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private let daysOfWeekTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupViews()
        setupTableView()
    }
    
    private func setupViews() {
        [pageTitle, daysOfWeekTableView, doneButton].forEach { view.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            pageTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            daysOfWeekTableView.topAnchor.constraint(equalTo: pageTitle.bottomAnchor, constant: 38),
            daysOfWeekTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            daysOfWeekTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            daysOfWeekTableView.heightAnchor.constraint(equalToConstant: CGFloat(weekDays.count * 75)),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: daysOfWeekTableView.leadingAnchor),
            doneButton.trailingAnchor.constraint(equalTo: daysOfWeekTableView.trailingAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }
    
    private func setupTableView() {
        daysOfWeekTableView.dataSource = self
        daysOfWeekTableView.delegate = self
        daysOfWeekTableView.register(TrackerOptionsCell.self, forCellReuseIdentifier: TrackerOptionsCell.reuseIdentifier)
        daysOfWeekTableView.layer.cornerRadius = 16
    }
    
    @objc
    private func doneButtonTapped() {
        delegate?.saveSchedule(weekSchedule: self.weekSchedule)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackerOptionsCell.reuseIdentifier, for: indexPath) as? TrackerOptionsCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        
        let adjustedIndex = (indexPath.row + 1) % weekDays.count // Вычисляем индекс с учетом сдвига
        
        let cellName = weekDays[adjustedIndex]
        let cellAdditionalUIElement = CellElement.daySelectionSwitch
        cell.configCell(nameLabel: cellName.dayName, element: cellAdditionalUIElement, indexPath: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        SeparatorLineHelper.configSeparatingLine(tableView: tableView, cell: cell, indexPath: indexPath)
    }
}

extension ScheduleViewController: SwitcherProtocolDelegate {
    func receiveSwitcherValue(isSelected: Bool, indexPath: IndexPath) {
        let adjustedIndex = (indexPath.row + 1) % weekDays.count // Применяем сдвиг индекса
        
        let weekElement = weekDays[adjustedIndex]
        if isSelected {
            weekSchedule.append(weekElement)
        } else {
            if let index = weekSchedule.firstIndex(of: weekElement) {
                weekSchedule.remove(at: index)
            }
        }
    }
}
