import Foundation

struct ErrorViewModel: Equatable {
    let title: String
    let message: String
    let buttonTitle: String?
    let shouldRetry: Bool
    
    // Se shouldRetry for true, a View deve exibir o botão com buttonTitle
}

enum ViewState<Content: Equatable>: Equatable {
    case idle
    case loading
    case empty
    case error(ErrorViewModel)
    case success(Content)
}
