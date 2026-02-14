import UIKit

final class URLHistoryCell: UITableViewCell {
    
    static let identifier = "URLHistoryCell"
    
    // MARK: - Event Closure
    var onCopy: ((String) -> Void)?
    
    private var shortLinkToCopy: String?
    
    // MARK: - UI Elements
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [labelsStack, copyButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var labelsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [originalUrlLabel, shortUrlLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private lazy var originalUrlLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var shortUrlLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .systemBlue
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(localized: .iconCopy)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray2
        button.addTarget(self, action: #selector(didTapCopy), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViewConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration Method
    func configure(original: String, short: String) {
        originalUrlLabel.text = original
        shortUrlLabel.text = short
        shortLinkToCopy = short
        
        // Reset do estado do botão (caso tenha sido reutilizado logo após uma animação)
        copyButton.setImage(UIImage(localized: .iconCopy), for: .normal)
        copyButton.tintColor = .systemGray2
    }
    
    // MARK: - Actions
    @objc private func didTapCopy() {
        guard let link = shortLinkToCopy else { return }
        onCopy?(link)
        animateCopyFeedback()
    }
    
    private func animateCopyFeedback() {
        let originalImage = UIImage(localized: .iconCopy)
        let feedbackImage = UIImage(localized: .iconCheckmark)
        
        UIView.transition(with: copyButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.copyButton.setImage(feedbackImage, for: .normal)
            self.copyButton.tintColor = .systemGreen
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self = self else { return }
                UIView.transition(with: self.copyButton, duration: 0.2, options: .transitionCrossDissolve) {
                    self.copyButton.setImage(originalImage, for: .normal)
                    self.copyButton.tintColor = .systemGray2
                }
            }
        }
    }
}

// MARK: - ViewConfiguration
extension URLHistoryCell: ViewConfiguration {
    
    func buildHierarchy() {
        contentView.addSubview(mainStack)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            copyButton.widthAnchor.constraint(equalToConstant: 44),
            copyButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func configureViews() {
        backgroundColor = .clear
        selectionStyle = .none
    }
}
