import Foundation

protocol URLShortenerServiceProtocol {
    func shortenURL(urlString: String) async throws -> ShortenedURL
}
