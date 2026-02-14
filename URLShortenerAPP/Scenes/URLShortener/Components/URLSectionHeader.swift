import UIKit

final class URLSectionHeader: UITableViewHeaderFooterView {
    
    static let identifier = "URLSectionHeader"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        // CORREÇÃO: LocalizedKey
        label.text = String(localized: .uiHeaderRecentHistory)
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViewConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - ViewConfiguration
extension URLSectionHeader: ViewConfiguration {
    
    func buildHierarchy() {
        contentView.addSubview(titleLabel)
    }
    
    func setupConstraints() {
            // Criamos as constraints que conflitam com prioridade menor
            let trailing = titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
            let bottom = titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            
            // Prioridade 750 permite que o sistema as ignore enquanto a View pai for zero
            trailing.priority = .defaultHigh
            bottom.priority = .defaultHigh
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
                trailing,
                bottom
            ])
        }
    
    func configureViews() {
        contentView.backgroundColor = .systemBackground
    }
}
