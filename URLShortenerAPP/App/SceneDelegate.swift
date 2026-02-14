import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    // Mantemos uma referência forte ao Coordinator para que ele não seja desalocado da memória
    var mainCoordinator: MainCoordinator?

    func scene(
        _ scene: UIScene, willConnectTo
        session: UISceneSession, options
        connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 1. Instanciação da Navigation Controller raiz
        let navigationController = UINavigationController()
        
        // 2. Inicialização do Coordinator
        mainCoordinator = MainCoordinator(navigationController: navigationController)
        mainCoordinator?.start()
        
        // 3. Configuração da Window manual (Sem Storyboard)
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
