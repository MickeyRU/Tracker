//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 02.08.2023.
//

import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func userAddNewCategory(viewController: UIViewController, category: TrackerCategory)
}

final class NewCategoryViewController: UIViewController {
    weak var delegate: NewCategoryViewControllerDelegate?
    private let viewModel: NewCategoryViewModel
    
    private var pageTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая Категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private lazy var categoryNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(red: 0.9, green: 0.91, blue: 0.92, alpha: 0.3)
        textField.placeholder = "Введите название категории"
        textField.layer.cornerRadius = 16
        textField.delegate = self
        
        // Создаем отступ, для текста в плейсхолдере
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.layer.cornerRadius = 16
        button.backgroundColor = .gray
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(viewModel: NewCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupViews()
    }
    
    @objc
    private func doneButtonTapped() {
        guard let categoryName = categoryNameTextField.text else { return }
        let newCategory = TrackerCategory(name: categoryName, trackers: [])
        delegate?.userAddNewCategory(viewController: self, category: newCategory)
    }
    
    func bind() {
        viewModel.$isNameFieldFilled.bind { [weak self] isFilled in
            guard let self = self else { return }
            updateButtonStatus(isAllowed: isFilled)
        }
    }
    
    private func setupViews() {
        [pageTitleLabel, categoryNameTextField, doneButton].forEach { view.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            pageTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
            categoryNameTextField.topAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: 38),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }
    
    private func updateButtonStatus(isAllowed: Bool) {
        if isAllowed {
            doneButton.isUserInteractionEnabled = true
            doneButton.backgroundColor = .black
        } else {
            doneButton.isUserInteractionEnabled = false
            doneButton.backgroundColor = .gray
        }
    }
}

// MARK: - UITextFieldDelegate

extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        viewModel.checkNameFieldFilled(text: textField.text)
        return true
    }
}
