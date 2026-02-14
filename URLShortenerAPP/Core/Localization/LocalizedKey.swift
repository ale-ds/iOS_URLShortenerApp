import Foundation

public enum LocalizedKey: String, CustomIdentifier {
    
    // MARK: - Network Errors
    case networkErrorInvalidURL
    case networkErrorNoConnectivity
    case networkErrorTimeout
    case networkErrorClient
    case networkErrorServer
    case networkErrorDecode
    case networkErrorUnknown
    
    // MARK: - Domain Errors
    case domainErrorInvalidURL
    
    // MARK: - UI
    case uiURLShortenerTitle
    case uiInputPlaceholder
    case uiButtonShorten
    case uiHeaderRecentHistory
    case uiEmptyStateTitle
    case uiEmptyStateMessage
    case uiActionCopy
    case uiFeedbackCopied
    case uiButtonRetry
    case uiButtonClose
}
