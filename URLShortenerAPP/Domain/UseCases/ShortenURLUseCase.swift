import Foundation

protocol ShortenURLUseCaseProtocol {
    func execute(url: String) async throws -> ShortenedURL
}

final class ShortenURLUseCase: ShortenURLUseCaseProtocol {
    
    private let service: URLShortenerServiceProtocol
    
    init(service: URLShortenerServiceProtocol) {
        self.service = service
    }
    
    func execute(url: String) async throws -> ShortenedURL {
        let cleanURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let validUrl = URL(string: cleanURL),
              let scheme = validUrl.scheme,
              ["http", "https"].contains(scheme.lowercased()),
              let host = validUrl.host, !host.isEmpty else {
            
            throw DomainError.invalidURL
        }
        
        return try await service.shortenURL(urlString: cleanURL)
    }
}
