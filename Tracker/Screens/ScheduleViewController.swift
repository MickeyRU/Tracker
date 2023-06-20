//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 20.06.2023.
//

import UIKit

protocol ScheduleProtocol: AnyObject {
    func updateSchedule(weekSchedule: WeekSchedule)
}

final class ScheduleViewController: UIViewController {
    weak var delegate: ScheduleProtocol?
    
    private var weekSchedule = WeekSchedule()
    
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
    
    private let doneButton: UIButton = {
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
    
    @objc
    private func doneButtonTapped() {
        delegate?.updateSchedule(weekSchedule: self.weekSchedule)
        dismiss(animated: true)
    }
    
    private func setupViews() {
        [pageTitle, daysOfWeekTableView, doneButton].forEach { view.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            pageTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            daysOfWeekTableView.topAnchor.constraint(equalTo: pageTitle.bottomAnchor, constant: 38),
            daysOfWeekTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            daysOfWeekTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            daysOfWeekTableView.heightAnchor.constraint(equalToConstant: CGFloat(weekSchedule.daysOfWeek.count * 75)),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: daysOfWeekTableView.leadingAnchor),
            doneButton.trailingAnchor.constraint(equalTo: daysOfWeekTableView.trailingAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }
    
    private func setupTableView() {
        daysOfWeekTableView.dataSource = self
        daysOfWeekTableView.delegate = self
        daysOfWeekTableView.register(TrackerDetailsCell.self, forCellReuseIdentifier: TrackerDetailsCell.reuseIdentifier)
        daysOfWeekTableView.layer.cornerRadius = 16
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekSchedule.daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackerDetailsCell.reuseIdentifier, for: indexPath) as? TrackerDetailsCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        let cellName = weekSchedule.daysOfWeek[indexPath.row].name
        let cellAdditionalUIElement = CellElement.daySelectionSwitch
        cell.configurate(nameLabel: cellName, element: cellAdditionalUIElement)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        if indexPath.row == 0 {
        //            // ToDo: реализовать выбор категории
        //            print("Нажали кнопку категория")
        //        } else {
        //            // ToDo: реализовать выбор расписания
        //            print("Нажали кнопку расписание")
        //        }
        //        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ScheduleViewController: SwitcherProtocolDelegate {
    func receiveValue(at cell: TrackerDetailsCell, isSelected: Bool) {
        // Получаем индекс ячейки
        guard let indexPath = daysOfWeekTableView.indexPath(for: cell) else {
            return
        }
        weekSchedule.daysOfWeek[indexPath.row].isSelected = isSelected
    }
}
