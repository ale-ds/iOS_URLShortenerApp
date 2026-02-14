import Foundation

protocol URLShortenerPresentationLogic {
    func presentShortenedURL(response: URLShortenerModels.Shorten.Response)
    func presentError(response: URLShortenerModels.Error.Response)
    func presentLoading()
}

final class URLShortenerPresenter: URLShortenerPresentationLogic {
    
    weak var viewController: URLShortenerDisplayLogic?
    
    func presentLoading() {
        viewController?.display(state: .loading)
    }
    
    func presentShortenedURL(response: URLShortenerModels.Shorten.Response) {
        // Mapeia o histórico completo recebido do Interactor para ViewModels
        let historyViewModels = response.history.map { item in
            URLShortenerModels.Shorten.HistoryItem(
                original: item.originalURL,
                short: item.shortURL,
                alias: item.alias
            )
        }
        
        let viewModel = URLShortenerModels.Shorten.ViewModel(
            shortURL: response.shortenedURL.shortURL,
            originalURL: response.shortenedURL.originalURL,
            history: historyViewModels
        )
        
        viewController?.display(state: .success(viewModel))
    }
    
    func presentError(response: URLShortenerModels.Error.Response) {
        let errorViewModel = makeErrorViewModel(from: response.error)
        viewController?.display(state: .error(errorViewModel))
    }
    
    private func makeErrorViewModel(from error: Error) -> ErrorViewModel {
        var title = ""
        var message = ""
        var shouldRetry = false
        
        if let networkError = error as? NetworkError {
            title = String(localized: .networkErrorUnknown)
            message = networkError.localizedDescription
            
            switch networkError {
            case .timeout, .noConnectivity, .serverError:
                shouldRetry = true
            default:
                shouldRetry = false
            }
        } else if let domainError = error as? DomainError {
            title = String(localized: .networkErrorInvalidURL)
            message = domainError.localizedDescription
            shouldRetry = false
        } else {
            title = String(localized: .networkErrorUnknown)
            message = String(localized: .networkErrorUnknown)
            shouldRetry = true
        }
        
        return ErrorViewModel(
            title: title,
            message: message,
            buttonTitle: shouldRetry ? String(localized: .uiButtonRetry) : nil,
            shouldRetry: shouldRetry
        )
    }
}
