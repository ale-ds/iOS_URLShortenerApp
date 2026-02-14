import Foundation

enum DomainError: Error, Equatable, LocalizedError {
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: .domainErrorInvalidURL)
        }
    }
}
