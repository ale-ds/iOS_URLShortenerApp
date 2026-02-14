import Foundation

enum URLShortenerEndpoint: Endpoint {
    case createAlias(url: String)
    
    var path: String {
        switch self {
        case .createAlias:
            return "/api/alias"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createAlias:
            return .post
        }
    }
    
    var header: [String : String]? {
        return nil // Retorna nil explicitamente pois não há headers adicionais neste endpoint específico.
    }
    
    var body: [String : Any]? {
        switch self {
        case .createAlias(let url):
            return ["url": url]
        }
    }
}
