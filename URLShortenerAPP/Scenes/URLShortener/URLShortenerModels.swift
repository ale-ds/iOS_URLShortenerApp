import Foundation

enum URLShortenerModels {
    
    // MARK: - Use Cases
    enum Shorten {
        struct Request {
            let url: String
        }
        
        struct Response {
            let shortenedURL: ShortenedURL
            let history: [ShortenedURL]
        }
        
        struct ViewModel: Equatable {
            let shortURL: String
            let originalURL: String
            let history: [HistoryItem]
        }
        
        struct HistoryItem: Equatable {
            let original: String
            let short: String
            let alias: String
        }
    }
    
    enum Error {
        struct Response {
            let error: Swift.Error
        }
        // ViewModel de erro utiliza o ErrorViewModel definido no Core/ViewState
    }
}
