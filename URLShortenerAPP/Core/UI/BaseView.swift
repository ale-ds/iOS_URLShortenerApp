import UIKit

class BaseView: UIView, ViewConfiguration {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewConfiguration()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewConfiguration Methods
    func buildHierarchy() {}
    
    func setupConstraints() {}
    
    func configureViews() {
        backgroundColor = .systemBackground
    }
}
