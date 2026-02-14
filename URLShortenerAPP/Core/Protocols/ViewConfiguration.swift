import UIKit

protocol ViewConfiguration: AnyObject {
    func buildHierarchy()
    func setupConstraints()
    func configureViews()
    func setupViewConfiguration()
}

extension ViewConfiguration {
    
    func setupViewConfiguration() {
        buildHierarchy()
        setupConstraints()
        configureViews()
    }
    
    // Implementação padrão opcional para evitar código repetitivo se não houver configuração extra
    func configureViews() {}
}
