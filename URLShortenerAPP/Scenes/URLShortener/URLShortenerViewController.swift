import UIKit

protocol Pasteboarder {
    func setString(_ string: String)
}

// Extensão para que o UIPasteboard cumpra o protocolo
extension UIPasteboard: Pasteboarder {
    func setString(_ string: String) {
        self.string = string
    }
}

protocol URLShortenerDisplayLogic: AnyObject {
    func display(state: ViewState<URLShortenerModels.Shorten.ViewModel>)
}

final class URLShortenerViewController: UIViewController, URLShortenerDisplayLogic {
    
    var interactor: URLShortenerBusinessLogic?
    var pasteboard: Pasteboarder = UIPasteboard.general
    
    private lazy var contentView: URLShortenerView = {
        let view  = URLShortenerView()
        view.onShortenRequested = { [weak self] urlText in
            self?.request(text: urlText, state: .loading)
        }
        
        view.onRetryRequested = { [weak self] urlText in
            self?.request(text: urlText, state: .loading)
        }
        
        view.onTyping = { [weak self] in
            self?.display(state: .idle)
        }
        
        view.onCopyRequested = { [weak self] shortURL in
            self?.pasteboard.setString(shortURL)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        return view
    }()
    
    override func loadView() {
        self.view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(localized: .uiURLShortenerTitle)
        display(state: .idle)
        monitorarInternet()
    }
    
    // MARK: - Actions
    private func request(text: String, state: ViewState<URLShortenerModels.Shorten.ViewModel>) {
        let request = URLShortenerModels.Shorten.Request(url: text)
        interactor?.shortenURL(request: request)
    }
    
    // MARK: - Display Logic
    func display(state: ViewState<URLShortenerModels.Shorten.ViewModel>) {
        DispatchQueue.main.async { [weak self] in
            self?.contentView.update(state: state)
        }
    }
    
    func monitorarInternet() {
        Task {
            // 1. Chamamos o nosso stream
            let stream = NetworkMonitor.shared.statusStream()
            
            print("Esperando mudanças de rede...")
            
            // 2. O código "pausa" aqui e espera cada nova atualização
            for await isConnected in stream {
                if isConnected {
                    print("✅ Conectado! Pode baixar os dados.")
                } else {
                    print("❌ Offline. Exibindo aviso ao usuário.")
                }
            }
        }
    }
}
