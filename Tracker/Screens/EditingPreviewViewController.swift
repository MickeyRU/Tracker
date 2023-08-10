//
//  EditingPreviewViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 07.08.2023.
//

import UIKit

final class EditingPreviewViewController: UIViewController {
    private var previewSize: CGSize? {
        didSet {
            if let size = previewSize {
                self.preferredContentSize = size
            }
        }
    }

    private var backGroundViewColor: UIView = {
        let view = UIView()
        return view
    }()
    
    private var emojiLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private var trackerTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
     
    func configureView(sizeForPreview: CGSize, tracker: Tracker) {
        previewSize = sizeForPreview
        backGroundViewColor.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        trackerTextLabel.text = tracker.name
    }
    
    private func setupViews() {
        [backGroundViewColor, emojiLabel, trackerTextLabel].forEach { view.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            backGroundViewColor.topAnchor.constraint(equalTo: view.topAnchor),
            backGroundViewColor.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backGroundViewColor.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backGroundViewColor.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalTo: emojiLabel.widthAnchor, multiplier: 1),
            emojiLabel.topAnchor.constraint(equalTo: backGroundViewColor.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: backGroundViewColor.leadingAnchor, constant: 12),
            
            trackerTextLabel.leadingAnchor.constraint(equalTo: emojiLabel.leadingAnchor),
            trackerTextLabel.bottomAnchor.constraint(equalTo: backGroundViewColor.bottomAnchor, constant: -12),
            trackerTextLabel.trailingAnchor.constraint(equalTo: backGroundViewColor.trailingAnchor, constant: -12),
        ])
    }
}
