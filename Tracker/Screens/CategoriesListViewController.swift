//
//  CategoriesListViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 31.07.2023.
//

import UIKit

final class CategoriesListViewController: UIViewController {
    
    ///   View (Представление):
    ///   формирует пользовательский интерфейс (экраны, кнопки и так далее);
    ///   наблюдает за изменениями данных ViewModel через байндинг, при изменениях меняет интерфейс;
    ///   вызывает команды ViewModel, когда пользователь воздействует на какой-либо элемент интерфейса.
    
    private var viewModel: CategoriesListViewModel
    
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
    
    init(viewModel: CategoriesListViewModel) {
        self.viewModel = viewModel
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
    }
    
    @objc private func addCategoryButtonTapped() {
        // ToDo: - функционал добавления категории к трекеру
    }
        
     func bind() {
        viewModel.$categories.bind { [weak self] _ in
            guard let self = self else { return }
            self.categoriesTableView.reloadData()
        }
    }
    
    private func setupViews() {
        [pageTitleLabel, categoriesTableView, addCategoryButton].forEach { view.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            pageTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            categoriesTableView.topAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: 38),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTableView.heightAnchor.constraint(equalToConstant: CGFloat(viewModel.categories.count * 75)),
            
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
    }
}

// MARK: - UITableViewDataSource
extension CategoriesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier) as? CategoryCell else { return UITableViewCell() }
//        cell.configCell(nameLabel: String)
        // ToDo: - дописать настройку ячейки
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
}
