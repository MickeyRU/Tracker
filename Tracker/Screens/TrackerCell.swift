//
//  TrackerCell.swift
//  Tracker
//
//  Created by Павел Афанасьев on 18.06.2023.
//

import UIKit

protocol DaysCountProtocol: AnyObject {
    func changeDaysCount(at cell: TrackerCell, isDayCountIncreased: Bool)
}

final class TrackerCell: UICollectionViewCell {
    weak var delegate: DaysCountProtocol?
    
    static let reuseIdentifier = "TrackerCell"
    
    var colorBackGroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.2, green: 0.81, blue: 0.41, alpha: 1.0)
        view.layer.cornerRadius = 16
        return view
    }()
    
    var emoji: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var trackerTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Поливать растения"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    var completedDaysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = "0 дней"
        return label
    }()
    
    private let addDaysButton: UIButton = {
        let button = UIButton()
        button.setImage(Images.addDaysButtonImage, for: .normal)
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
        delegate?.changeDaysCount(at: self, isDayCountIncreased: isAddDaysButtonTapped)
        if isAddDaysButtonTapped {
            addDaysButton.setImage(Images.addDaysButtonClickedImage, for: .normal)
        } else {
            addDaysButton.setImage(Images.addDaysButtonImage, for: .normal)
        }
        // ToDo: - С помощью кнопки можно добавить запись, что этот трекер нужно пометить как выполненный для даты, выбранной в UIDatePicker.
    }
    
    private func setupViews() {
        [colorBackGroundView, emoji, trackerTextLabel, addDaysButton, completedDaysLabel].forEach { contentView.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            colorBackGroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorBackGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorBackGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorBackGroundView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
            
            emoji.widthAnchor.constraint(equalToConstant: 24),
            emoji.heightAnchor.constraint(equalTo: emoji.widthAnchor, multiplier: 1),
            emoji.topAnchor.constraint(equalTo: colorBackGroundView.topAnchor, constant: 12),
            emoji.leadingAnchor.constraint(equalTo: colorBackGroundView.leadingAnchor, constant: 12),
            
            trackerTextLabel.leadingAnchor.constraint(equalTo: emoji.leadingAnchor),
            trackerTextLabel.bottomAnchor.constraint(equalTo: colorBackGroundView.bottomAnchor, constant: -12),
            trackerTextLabel.trailingAnchor.constraint(equalTo: colorBackGroundView.trailingAnchor, constant: -12),
            
            addDaysButton.widthAnchor.constraint(equalToConstant: 34),
            addDaysButton.heightAnchor.constraint(equalToConstant: 34),
            addDaysButton.topAnchor.constraint(equalTo: colorBackGroundView.bottomAnchor, constant: 8),
            addDaysButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            completedDaysLabel.topAnchor.constraint(equalTo: colorBackGroundView.bottomAnchor, constant: 16),
            completedDaysLabel.leadingAnchor.constraint(equalTo: trackerTextLabel.leadingAnchor),
            completedDaysLabel.trailingAnchor.constraint(equalTo: addDaysButton.leadingAnchor, constant: -8)
        ])
    }
}
