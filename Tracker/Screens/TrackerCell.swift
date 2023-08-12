//
//  TrackerCell.swift
//  Tracker
//
//  Created by Павел Афанасьев on 18.06.2023.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    
    private let analyticsService = AnalyticsService.shared
    
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    weak var delegate: TrackerCellDelegate?

    private var isCompletedToday: Bool = false
    
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
    
    private lazy var trackButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(trackButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var pinnedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Images.pinnedTrackerImage
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required  init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCell(tracker: Tracker, isCompletedToday: Bool,  indexPath: IndexPath, completedDays: Int) {
        layer.cornerRadius = 16
        
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        
        self.emojiLabel.text = tracker.emoji
        self.trackerTextLabel.text = tracker.name
        self.backGroundViewColor.backgroundColor = tracker.color
        self.trackButton.tintColor = tracker.color
        self.pinnedImageView.isHidden = tracker.isPinned ? false : true
        updateDayCountLabelAndButton(completedDays: completedDays)
    }
    
    func updateDayCountLabelAndButton(completedDays: Int) {
        // Формируем итоговый лейбл с учетом склонения слова "день"
        let formattedLabel = formatDayLabel(daysCount: completedDays)
        self.completedDaysLabel.text = formattedLabel
        
        let image = isCompletedToday ? Images.addDaysButtonClickedImage : Images.addDaysButtonImage
          trackButton.setImage(image, for: .normal)
    }
    
    private func setupViews() {
        [backGroundViewColor, emojiLabel, trackerTextLabel, trackButton, completedDaysLabel, pinnedImageView].forEach { contentView.addViewsWithNoTAMIC($0) }
        
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
            
            trackButton.widthAnchor.constraint(equalToConstant: 34),
            trackButton.heightAnchor.constraint(equalToConstant: 34),
            trackButton.topAnchor.constraint(equalTo: backGroundViewColor.bottomAnchor, constant: 8),
            trackButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            completedDaysLabel.topAnchor.constraint(equalTo: backGroundViewColor.bottomAnchor, constant: 16),
            completedDaysLabel.leadingAnchor.constraint(equalTo: trackerTextLabel.leadingAnchor),
            completedDaysLabel.trailingAnchor.constraint(equalTo: trackButton.leadingAnchor, constant: -8),
            
            pinnedImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            pinnedImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4)
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
    
    @objc
    private func trackButtonTapped() {
        analyticsService.report(event: "click", params: [
            "screen": "Main",
            "item": "track"
        ])
        
        guard
            let trackerId = trackerId,
            let indexPath = indexPath
        else {
            assertionFailure("no tracker id")
            return
        }
        if isCompletedToday {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
}
