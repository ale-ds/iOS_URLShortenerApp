import Foundation

final class URLShortenerService: URLShortenerServiceProtocol {
    private let client: HTTPClientProtocol
    
    init(client: HTTPClientProtocol = HTTPClient()) {
        self.client = client
    }
    
    func shortenURL(urlString: String) async throws -> ShortenedURL {
        let endpoint = URLShortenerEndpoint.createAlias(url: urlString)
        let dto = try await client.sendRequest(endpoint: endpoint, responseModel: AliasResponseDTO.self)
        return URLShortenerMapper.map(dto: dto)
    }
}
