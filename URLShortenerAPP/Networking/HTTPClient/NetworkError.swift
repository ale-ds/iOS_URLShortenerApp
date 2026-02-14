import Foundation

enum NetworkError: Error, Equatable, LocalizedError {
    case invalidURL       // URL inválida (Construção)
    case noConnectivity   // Falta de conectividade
    case timeout          // Timeout
    case clientError(Int) // Erros HTTP 4xx
    case serverError(Int) // Erros HTTP 5xx
    case decode           // Erro de parser
    case unknown          // Fallback obrigatório (safety)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: .networkErrorInvalidURL)
        case .noConnectivity:
            return String(localized: .networkErrorNoConnectivity)
        case .timeout:
            return String(localized: .networkErrorTimeout)
        case .clientError(let code):
            let format = String(localized: .networkErrorClient)
            return String(format: format, code)
        case .serverError(let code):
            let format = String(localized: .networkErrorServer)
            return String(format: format, code)
        case .decode:
            return String(localized: .networkErrorDecode)
        case .unknown:
            return String(localized: .networkErrorUnknown)
        }
    }
}
