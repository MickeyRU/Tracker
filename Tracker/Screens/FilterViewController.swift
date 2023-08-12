import UIKit

final class FilterViewController: UIViewController {
    private let filters = ["Все трекеры", "Трекеры на сегодня", "Завешенные", "Не завршенные"]

    private let pageTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private lazy var filtersTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setupViews()
        configureTableView()
    }
    
    private func setupViews() {
        [pageTitleLabel, filtersTableView].forEach{ view.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            pageTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            filtersTableView.topAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: 38),
            filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTableView.heightAnchor.constraint(equalToConstant: CGFloat(filters.count * 75))
        ])
    }
    
    private func configureTableView() {
        filtersTableView.dataSource = self
        filtersTableView.delegate = self
        filtersTableView.isScrollEnabled = false
        
        filtersTableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        filtersTableView.layer.cornerRadius = 16
    }
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as?
        CategoryCell else { fatalError("Invalid cell configuration") }
        
        cell.configCell(nameLabel: filters[indexPath.row], isSelected: true)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        SeparatorLineHelper.configSeparatingLine(tableView: tableView, cell: cell, indexPath: indexPath)
    }
}
