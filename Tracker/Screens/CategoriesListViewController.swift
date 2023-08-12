//
//  CategoriesListViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 31.07.2023.
//

import UIKit

protocol CategoriesListViewControllerDelegate: AnyObject {
    func categoryIsChosen(categoryName: String)
}

final class CategoriesListViewController: UIViewController {
    weak var delegate: CategoriesListViewControllerDelegate?
    
    private var viewModel: CategoriesListViewModel
    private var chosenCategoryName: String?
    
    private let placeholderView = PlaceholderView(
        title: "Привычки и события можно объединить по смыслу?"
    )
    
    private let pageTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var categoriesTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    init(viewModel: CategoriesListViewModel, chosenCategory: String?) {
        self.viewModel = viewModel
        self.chosenCategoryName = chosenCategory
        viewModel.loadCategoriesList()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
        setupTableView()
        checkCategoryList()
    }
    
    @objc
    private func addCategoryButtonTapped() {
        let model = NewCategoryModel()
        let viewModel = NewCategoryViewModel(model: model)
        let destinationVC = NewCategoryViewController(viewModel: viewModel)
        destinationVC.delegate = self
        present(destinationVC, animated: true)
    }
    
    func bind() {
        viewModel.$categories.bind { [weak self] _ in
            guard let self = self else { return }
            self.categoriesTableView.reloadData()
        }
    }
    
    private func setupViews() {
        [pageTitleLabel, categoriesTableView, addCategoryButton, placeholderView].forEach { view.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            pageTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            categoriesTableView.topAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: 38),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -39),
            
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }
    
    private func setupTableView() {
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        categoriesTableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        categoriesTableView.layer.cornerRadius = 16
    }
    
    private func checkCategoryList() {
        placeholderView.isHidden = viewModel.categories.count != 0
    }
}
    
    // MARK: - UITableViewDataSource
    extension CategoriesListViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            viewModel.categories.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier) as? CategoryCell else { return UITableViewCell() }
            let cellName = viewModel.categories[indexPath.row].name
            var isSelected = false
            if let chosenCategoryName = chosenCategoryName {
                isSelected = cellName == chosenCategoryName
            }
            cell.configCell(nameLabel: cellName, isSelected: isSelected)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate

    extension CategoriesListViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            75
        }
        
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            SeparatorLineHelper.configSeparatingLine(tableView: tableView, cell: cell, indexPath: indexPath)
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedCategory = viewModel.categories[indexPath.row]
            delegate?.categoryIsChosen(categoryName: selectedCategory.name)
            dismiss(animated: true)
        }
    }
    
    extension CategoriesListViewController: NewCategoryViewControllerDelegate {
        func userAddNewCategory(viewController: UIViewController, category: TrackerCategory) {
            viewController.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                viewModel.addNewCategory(category: category)
                categoriesTableView.reloadData()
                checkCategoryList()
            }
        }
    }
    
    extension CategoriesListViewController: CreateTrackerViewControllerDelegate {
        func chosenCategory(name: String) {
            chosenCategoryName = name
        }
    }
