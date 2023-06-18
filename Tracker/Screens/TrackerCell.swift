//
//  TrackerCell.swift
//  Tracker
//
//  Created by Павел Афанасьев on 18.06.2023.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    
    var colorBackGroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.2, green: 0.81, blue: 0.41, alpha: 1.0)
        view.layer.cornerRadius = 16
        return view
    }()
    
    var emojiImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart")
        return imageView
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
        return label
    }()
    
    private let addDaysButton: UIButton = {
        let button = UIButton()
        button.setImage(Images.addDaysButtonImage, for: .normal)
        button.addTarget(self, action: #selector(addDaysButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required  init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func addDaysButtonTapped() {
        // ToDo: - С помощью кнопки можно добавить запись, что этот трекер нужно пометить как выполненный для даты, выбранной в UIDatePicker.
    }
    
    private func setupViews() {
        [colorBackGroundView, emojiImage, trackerTextLabel].forEach {contentView.addViewsWithTAMIC($0)}
        
        NSLayoutConstraint.activate([
            colorBackGroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorBackGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorBackGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorBackGroundView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
            emojiImage.widthAnchor.constraint(equalToConstant: 24),
            emojiImage.heightAnchor.constraint(equalTo: emojiImage.widthAnchor, multiplier: 1),
            emojiImage.topAnchor.constraint(equalTo: colorBackGroundView.topAnchor, constant: 12),
            emojiImage.leadingAnchor.constraint(equalTo: colorBackGroundView.leadingAnchor, constant: 12),
            
            trackerTextLabel.leadingAnchor.constraint(equalTo: colorBackGroundView.leadingAnchor, constant: 12),
            trackerTextLabel.bottomAnchor.constraint(equalTo: colorBackGroundView.bottomAnchor, constant: -12),
            trackerTextLabel.trailingAnchor.constraint(equalTo: colorBackGroundView.trailingAnchor, constant: -12),


        ])
    }
}
