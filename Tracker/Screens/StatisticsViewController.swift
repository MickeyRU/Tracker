//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Павел Афанасьев on 18.06.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    private let viewModel: StatisticsViewModel
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Cтатистика"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    
    private let statisticCollectionView: UICollectionView = {
        let tableView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        return tableView
    }()
    
    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
        configTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getCompletedTrackersCount()
    }
    
    private func bind() {
        viewModel.$trackersCompletedTotaly.bind { [weak self] _ in
            guard let self = self else { return }
            self.statisticCollectionView.reloadData()
        }
    }
    
    private func setupViews() {
        [titleLabel, statisticCollectionView].forEach { view.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            statisticCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            statisticCollectionView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            statisticCollectionView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            statisticCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -126)
        ])
    }
    
    private func configTableView() {
        statisticCollectionView.register(StatisticsCell.self, forCellWithReuseIdentifier: StatisticsCell.reusableIdentifier)
        statisticCollectionView.dataSource = self
        statisticCollectionView.delegate = self
    }
}

// MARK: - UICollectionViewDataSource

extension StatisticsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatisticsCell.reusableIdentifier, for: indexPath) as? StatisticsCell else { return UICollectionViewCell() }
        let trackerFinishedCount = viewModel.trackersCompletedTotaly.count
        let cellName = "Трекеров завершено"
        cell.configureTitles(count: String(trackerFinishedCount), name: cellName)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension StatisticsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width - 32, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        12
    }
}
