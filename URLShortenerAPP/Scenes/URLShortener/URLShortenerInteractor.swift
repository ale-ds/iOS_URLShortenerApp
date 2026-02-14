import Foundation

protocol URLShortenerBusinessLogic {
    func shortenURL(request: URLShortenerModels.Shorten.Request)
}

protocol URLShortenerDataStore {
    var history: [ShortenedURL] { get set }
}

final class URLShortenerInteractor: URLShortenerBusinessLogic, URLShortenerDataStore {
    
    var presenter: URLShortenerPresentationLogic?
    var useCase: ShortenURLUseCaseProtocol
    
    // O Interactor é o detentor do estado (DataStore)
    var history: [ShortenedURL] = []
    
    // Configuração de Retry
    private let maxRetries = 2
    
    init(useCase: ShortenURLUseCaseProtocol) {
        self.useCase = useCase
    }
    
    func shortenURL(request: URLShortenerModels.Shorten.Request) {
        presenter?.presentLoading()
        
        Task {
            await performRequestWithRetry(url: request.url, attempt: 1)
        }
    }
    
    private func performRequestWithRetry(url: String, attempt: Int) async {
        do {
            let shortenedURL = try await useCase.execute(url: url)
            handleSuccess(shortenedURL: shortenedURL)
        } catch {
            await handleFailure(error: error, url: url, attempt: attempt)
        }
    }
    
    private func handleSuccess(shortenedURL: ShortenedURL) {
        history.insert(shortenedURL, at: 0)
        
        // Cria a resposta contendo todo o contexto necessário para a próxima camada
        let response = URLShortenerModels.Shorten.Response(
            shortenedURL: shortenedURL,
            history: history
        )
        
        presenter?.presentShortenedURL(response: response)
    }
    
    private func handleFailure(error: Error, url: String, attempt: Int) async {
        if shouldRetry(error: error, currentAttempt: attempt) {
            try? await Task.sleep(nanoseconds: UInt64(attempt) * 1_000_000_000)
            await performRequestWithRetry(url: url, attempt: attempt + 1)
        } else {
            let response = URLShortenerModels.Error.Response(error: error)
            presenter?.presentError(response: response)
        }
    }
    
    private func shouldRetry(error: Error, currentAttempt: Int) -> Bool {
        guard currentAttempt <= maxRetries else { return false }
        
        if let networkError = error as? NetworkError {
            switch networkError {
            case .timeout, .serverError, .noConnectivity:
                return true
            default:
                return false
            }
        }
        return false
    }
}
