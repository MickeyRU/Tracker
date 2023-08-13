import UIKit

final class StatisticsCell: UICollectionViewCell {
    static let reusableIdentifier = "StatisticsCell"
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupBorder()
        layer.cornerRadius = 16
    }
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTitles(count: String, name: String) {
        self.countLabel.text = count
        self.nameLabel.text = name
    }
    
    private func setupViews() {
        [countLabel, nameLabel].forEach { contentView.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            nameLabel.leadingAnchor.constraint(equalTo: countLabel.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: countLabel.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupBorder() {
        createGradientBorder(
            width: 1,
            cornerRadius: 12,
            colors: UIColor.gradientColors,
            startPoint: CGPoint(x: 1.0, y: 0.5),
            endPoint: CGPoint(x: 0.0, y: 0.5)
        )
    }
}
