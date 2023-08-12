//
//  TrackerUIHelper.swift
//  Tracker
//
//  Created by Павел Афанасьев on 11.08.2023.
//

import UIKit

enum TrackerViewControllerMode {
    case create(String, [String])
    case edit(Tracker, String, Int, [String])
}

final class TrackerUIHelper {
    
    func createScreenScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 920)
        return scrollView
    }
    
    func createPageTitle() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }
    
    func createdayCountLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        return label
    }
    
    func createTrackerNameTextField() -> UITextField {
        let textField = UITextField()
        textField.backgroundColor = UIColor(red: 0.9, green: 0.91, blue: 0.92, alpha: 0.3)
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 16
        
        // Создаем отступ, для текста в плейсхолдере
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }
    
    func createTrackerOptionsTableView() -> UITableView {
        return UITableView()
    }
    
    func createEmojiAndColorsCollectionView() -> UICollectionView {
        return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    func createCancelButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(red: 0.96, green: 0.42, blue: 0.42, alpha: 1.0), for: .normal)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = CGColor(red: 0.96, green: 0.42, blue: 0.42, alpha: 1.0)
        button.backgroundColor = .white
        return button
    }
    
    func createAcceptButton() -> UIButton {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        return button
    }
    
    func createButtonStackView() -> UIStackView {
        let stackView = UIStackView()
        return stackView
    }
}


