//
//  TrackerCell.swift
//  Tracker
//
//  Created by Павел Афанасьев on 18.06.2023.
//

import UIKit

protocol DaysCountProtocol: AnyObject {
    func changeDaysCount(at cell: TrackerCell, isDayCountIncreased: Bool, tracker: Tracker)
}

final class TrackerCell: UICollectionViewCell {
    weak var delegate: DaysCountProtocol?
    
    static let reuseIdentifier = "TrackerCell"
    
    private var tracker: Tracker?
    
    private var backGroundViewColor: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.2, green: 0.81, blue: 0.41, alpha: 1.0)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private var emojiLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private var trackerTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Поливать растения"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private var completedDaysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = "0 дней"
        return label
    }()
    
    private var addDaysButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(addDaysButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var isAddDaysButtonTapped = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required  init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func addDaysButtonTapped() {
        isAddDaysButtonTapped = !isAddDaysButtonTapped
        guard let tracker = tracker else { return }
        delegate?.changeDaysCount(at: self, isDayCountIncreased: isAddDaysButtonTapped, tracker: tracker)
        if isAddDaysButtonTapped {
            self.addDaysButton.setImage(Images.addDaysButtonClickedImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            self.addDaysButton.setImage(Images.addDaysButtonImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    func configCell(tracker: Tracker, trackerRecordsCount: Int, isButtonTapped: Bool) {
        isAddDaysButtonTapped = isButtonTapped
        self.tracker = tracker
        self.emojiLabel.text = tracker.emoji
        self.trackerTextLabel.text = tracker.name
        self.backGroundViewColor.backgroundColor = tracker.color
        self.addDaysButton.tintColor = tracker.color
        
        if isButtonTapped {
            self.addDaysButton.setImage(Images.addDaysButtonClickedImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            self.addDaysButton.setImage(Images.addDaysButtonImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        
        updateDayCountLabel(count: trackerRecordsCount)
    }
    
    func updateDayCountLabel(count: Int) {
        // Формируем итоговый лейбл с учетом склонения слова "день"
        let formattedLabel = formatDayLabel(daysCount: count)
        self.completedDaysLabel.text = formattedLabel
    }
    
    private func setupViews() {
        [backGroundViewColor, emojiLabel, trackerTextLabel, addDaysButton, completedDaysLabel].forEach { contentView.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            backGroundViewColor.topAnchor.constraint(equalTo: contentView.topAnchor),
            backGroundViewColor.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backGroundViewColor.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backGroundViewColor.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
            
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalTo: emojiLabel.widthAnchor, multiplier: 1),
            emojiLabel.topAnchor.constraint(equalTo: backGroundViewColor.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: backGroundViewColor.leadingAnchor, constant: 12),
            
            trackerTextLabel.leadingAnchor.constraint(equalTo: emojiLabel.leadingAnchor),
            trackerTextLabel.bottomAnchor.constraint(equalTo: backGroundViewColor.bottomAnchor, constant: -12),
            trackerTextLabel.trailingAnchor.constraint(equalTo: backGroundViewColor.trailingAnchor, constant: -12),
            
            addDaysButton.widthAnchor.constraint(equalToConstant: 34),
            addDaysButton.heightAnchor.constraint(equalToConstant: 34),
            addDaysButton.topAnchor.constraint(equalTo: backGroundViewColor.bottomAnchor, constant: 8),
            addDaysButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            completedDaysLabel.topAnchor.constraint(equalTo: backGroundViewColor.bottomAnchor, constant: 16),
            completedDaysLabel.leadingAnchor.constraint(equalTo: trackerTextLabel.leadingAnchor),
            completedDaysLabel.trailingAnchor.constraint(equalTo: addDaysButton.leadingAnchor, constant: -8)
        ])
    }
    
    private func formatDayLabel(daysCount: Int) -> String {
        let suffix: String
        
        if daysCount % 10 == 1 && daysCount % 100 != 11 {
            suffix = "день"
        } else if (daysCount % 10 == 2 && daysCount % 100 != 12) ||
                    (daysCount % 10 == 3 && daysCount % 100 != 13) ||
                    (daysCount % 10 == 4 && daysCount % 100 != 14) {
            suffix = "дня"
        } else {
            suffix = "дней"
        }
        
        return "\(daysCount) \(suffix)"
    }
}
