
import XCTest
import SnapshotTesting
@testable import URLShortener

final class URLShortenerViewSnapshotTests: XCTestCase {
    
    var sut: URLShortenerView!
    
    override func setUp() {
        super.setUp()
        // Configuração: iPhone 17 (393x852)
        sut = URLShortenerView(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        sut.overrideUserInterfaceStyle = .light
        sut.backgroundColor = .systemBackground
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Helpers
    private func makeHistoryItems() -> [URLShortenerModels.Shorten.HistoryItem] {
        return [
            .init(original: "https://www.google.com/search?q=swift", short: "http://short.com/abc", alias: "abc"),
            .init(original: "https://www.apple.com", short: "http://short.com/apple", alias: "apple"),
            .init(original: "https://github.com/pointfreeco/swift-snapshot-testing", short: "http://short.com/snapshot", alias: "snapshot")
        ]
    }
    
    // MARK: - Tests
    
    func testFullScreen_EmptyState() {
        // Given
        sut.update(state: .empty)
        
        // Then
        assertSnapshot(of: sut, as: .image, named: "FullScreen_Empty_iPhone17")
    }
    
    func testFullScreen_WithHistoryList() {
        // Given
        let history = makeHistoryItems()
        let viewModel = URLShortenerModels.Shorten.ViewModel(shortURL: "", originalURL: "", history: history)
        
        // When
        sut.update(state: .success(viewModel))
        
        // Then
        assertSnapshot(of: sut, as: .image, named: "FullScreen_List_iPhone17")
    }
    
    func testFullScreen_ErrorWithRetry_AndList() {
        // Given
        // 1. Popula lista
        let history = makeHistoryItems()
        let successViewModel = URLShortenerModels.Shorten.ViewModel(shortURL: "", originalURL: "", history: history)
        sut.update(state: .success(successViewModel))
        
        // 2. Simula erro de conexão (Retry ON)
        let errorVM = ErrorViewModel(
            title: "Erro de Conexão",
            message: "Não foi possível conectar. Verifique sua internet.",
            buttonTitle: "Tentar Novamente",
            shouldRetry: true
        )
        
        // When
        sut.update(state: .error(errorVM))
        
        // Then
        assertSnapshot(of: sut, as: .image, named: "FullScreen_Error_WithRetry_And_List_iPhone17")
    }
    
    func testFullScreen_ErrorNoRetry_AndList() {
        // Given
        // 1. Popula lista
        let history = makeHistoryItems()
        let successViewModel = URLShortenerModels.Shorten.ViewModel(shortURL: "", originalURL: "", history: history)
        sut.update(state: .success(successViewModel))
        
        // 2. Simula erro de validação/domínio (Retry OFF)
        let errorVM = ErrorViewModel(
            title: "URL Inválida",
            message: "A URL informada não parece válida. Verifique se começa com http:// ou https://",
            buttonTitle: nil,
            shouldRetry: false
        )
        
        // When
        sut.update(state: .error(errorVM))
        
        // Then
        assertSnapshot(of: sut, as: .image, named: "FullScreen_Error_NoRetry_And_List_iPhone17")
    }
    
    func testFullScreen_Loading() {
        // Given
        sut.update(state: .loading)
        
        // Then
        assertSnapshot(of: sut, as: .image, named: "FullScreen_Loading_iPhone17")
    }
}
