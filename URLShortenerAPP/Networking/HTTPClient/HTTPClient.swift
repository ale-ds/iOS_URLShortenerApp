import Foundation

protocol HTTPClientProtocol {
    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async throws -> T
}

final class HTTPClient: HTTPClientProtocol {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async throws -> T {
        guard let request = endpoint.urlRequest else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    print("❌ Decode Error: \(error)")
                    throw NetworkError.decode
                }
                
            case 400...499:
                // Mapeia 408 explicitamente para Timeout
                if httpResponse.statusCode == 408 {
                    throw NetworkError.timeout
                }
                throw NetworkError.clientError(httpResponse.statusCode)
                
            case 500...599:
                throw NetworkError.serverError(httpResponse.statusCode)
                
            default:
                throw NetworkError.unknown
            }
            
        } catch let error as NetworkError {
            throw error
            
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noConnectivity
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.unknown
            }
            
        } catch {
            throw NetworkError.unknown
        }
    }
}
