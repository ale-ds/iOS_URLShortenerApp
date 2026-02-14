import UIKit

final class MainCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        // Usa a Factory para desacoplar a montagem da navegação
        let viewController = URLShortenerFactory.make()
        navigationController.pushViewController(viewController, animated: false)
    }
}

// MARK: - Factory (Pattern sugerido para isolar a montagem VIP)
enum URLShortenerFactory {
    static func make() -> UIViewController {
        // Dependências de Networking e Domain
        // Obs: O HTTPClient e Service devem ser criados aqui ou injetados
        let httpClient = HTTPClient()
        let service = URLShortenerService(client: httpClient)
        let useCase = ShortenURLUseCase(service: service)
        
        let viewController = URLShortenerViewController()
        let interactor = URLShortenerInteractor(useCase: useCase)
        let presenter = URLShortenerPresenter()
        
        // Conexões VIP
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController // O Presenter deve ter weak var aqui
        
        return viewController
    }
}
