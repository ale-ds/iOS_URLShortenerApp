import XCTest
@testable import URLShortener

final class URLShortenerViewTests: XCTestCase {
    
    // MARK: - System Under Test
    var sut: URLShortenerView!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        sut = URLShortenerView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        sut.layoutIfNeeded() // Garanta carregamento das lazy vars
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - View Hierarchy Tests
    
    func test_init_shouldAddSubviews() throws {
        // Then
        XCTAssertNotNil(sut.urlInputView, "URLInputView deve ser inicializada")
        XCTAssertNotNil(sut.tableView, "TableView deve ser inicializada")
        XCTAssertNotNil(sut.emptyStateView, "EmptyStateView deve ser inicializada")
        
        XCTAssertTrue(try XCTUnwrap(sut.urlInputView).isDescendant(of: sut), "InputView deve estar na hierarquia")
        XCTAssertTrue(try XCTUnwrap(sut.tableView).isDescendant(of: sut), "TableView deve estar na hierarquia")
    }
    
    // MARK: - State Update Tests
    
    func test_update_empty_shouldShowEmptyStateAndHideTable() throws {
        // Given
        let emptyStateView = try XCTUnwrap(sut.emptyStateView)
        let tableView = try XCTUnwrap(sut.tableView)
        
        // When
        sut.update(state: .empty)
        
        // Then
        XCTAssertFalse(emptyStateView.isHidden, "EmptyState deve estar visível no estado .empty")
        XCTAssertTrue(tableView.isHidden, "TableView deve estar oculta no estado .empty")
    }
    
    func test_update_success_shouldHideEmptyStateAndReloadTable() throws {
        // Given
        let emptyStateView = try XCTUnwrap(sut.emptyStateView)
        let tableView = try XCTUnwrap(sut.tableView)
        
        let historyItem = URLShortenerModels.Shorten.HistoryItem(
            original: "orig", short: "short", alias: "alias"
        )
        let viewModel = URLShortenerModels.Shorten.ViewModel(
            shortURL: "short", originalURL: "orig", history: [historyItem]
        )
        
        // When
        sut.update(state: .success(viewModel))
        
        // Then
        XCTAssertTrue(emptyStateView.isHidden, "EmptyState deve sumir quando houver dados")
        XCTAssertFalse(tableView.isHidden, "TableView deve aparecer quando houver dados")
        
        // Valida Datasource
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 1, "TableView deve ter 1 linha")
    }
    
    func test_update_loading_shouldForwardToInputView() throws {
        // Given
        let inputView = try XCTUnwrap(sut.urlInputView)
        // Acessa o loader DENTRO da inputView via reflection
        let inputLoader: UIActivityIndicatorView? = inputView.extractElement(name: "loadingIndicator")
        
        // When
        sut.update(state: .loading)
        
        // Then
        XCTAssertTrue(inputLoader?.isAnimating ?? false, "O loader interno da InputView deve estar animando")
    }
    
    func test_update_error_shouldForwardToInputView() throws {
        // Given
        let errorVM = ErrorViewModel(title: "E", message: "M", buttonTitle: nil, shouldRetry: false)
        let inputView = try XCTUnwrap(sut.urlInputView)
        
        // When
        sut.update(state: .error(errorVM))
        
        // Then
        // Verifica se o container de erro da inputView ficou visível
        let errorContainer: UIView? = inputView.extractElement(name: "errorContainerView")
        XCTAssertFalse(errorContainer?.isHidden ?? true, "InputView deve mostrar erro")
    }
    
    // MARK: - Interaction / Closure Tests
    
    func test_interactions_shouldForwardShortenRequest() throws {
        // Given
        let inputView = try XCTUnwrap(sut.urlInputView)
        var capturedText: String?
        sut.onShortenRequested = { capturedText = $0 }
        
        // When
        // Dispara o closure interno da inputView
        inputView.onShorten?("http://test.com")
        
        // Then
        XCTAssertEqual(capturedText, "http://test.com", "A View deve repassar o evento de shorten")
    }
    
    func test_interactions_shouldForwardRetryRequest() throws {
        // Given
        let inputView = try XCTUnwrap(sut.urlInputView)
        var capturedText: String?
        sut.onRetryRequested = { capturedText = $0 }
        
        // When
        inputView.onRetry?("http://retry.com")
        
        // Then
        XCTAssertEqual(capturedText, "http://retry.com", "A View deve repassar o evento de retry")
    }
    
    func test_interactions_shouldForwardTyping() throws {
        // Given
        let inputView = try XCTUnwrap(sut.urlInputView)
        var typingCalled = false
        sut.onTyping = { typingCalled = true }
        
        // When
        inputView.onTyping?()
        
        // Then
        XCTAssertTrue(typingCalled, "A View deve repassar o evento de typing")
    }
    
    func test_interactions_shouldForwardCopyRequestFromCell() throws {
        // Given
        let viewModel = URLShortenerModels.Shorten.ViewModel(
            shortURL: "",
            originalURL: "",
            history: [.init(original: "A", short: "http://short", alias: "a")]
        )
        sut.update(state: .success(viewModel))
        
        let tableView = try XCTUnwrap(sut.tableView)
        let indexPath = IndexPath(row: 0, section: 0)
        
        // Simula criação da célula
        guard let cell = sut.tableView(tableView, cellForRowAt: indexPath) as? URLHistoryCell else {
            XCTFail("Não foi possível obter a célula correta")
            return
        }
        
        var capturedShortURL: String?
        sut.onCopyRequested = { capturedShortURL = $0 }
        
        // When
        // Dispara o closure da célula diretamente
        cell.onCopy?("http://short")
        
        // Then
        XCTAssertEqual(capturedShortURL, "http://short", "A View deve repassar o evento de copy vindo da célula")
    }
    
    // MARK: - DataSource Tests
    
    func test_tableView_numberOfRows_shouldMatchHistoryCount() throws {
        // Given
        let history = [
            URLShortenerModels.Shorten.HistoryItem(original: "1", short: "1", alias: "1"),
            URLShortenerModels.Shorten.HistoryItem(original: "2", short: "2", alias: "2")
        ]
        let vm = URLShortenerModels.Shorten.ViewModel(shortURL: "", originalURL: "", history: history)
        sut.update(state: .success(vm))
        
        let tableView = try XCTUnwrap(sut.tableView)
        
        // When
        let rows = sut.tableView(tableView, numberOfRowsInSection: 0)
        
        // Then
        XCTAssertEqual(rows, 2)
    }
    
    func test_tableView_header_shouldAppearOnlyWhenHistoryExists() throws {
        // Case 1: Empty
        sut.update(state: .empty)
        let tableView = try XCTUnwrap(sut.tableView)
        XCTAssertEqual(sut.tableView(tableView, heightForHeaderInSection: 0), 0, "Header deve ter altura 0 se vazio")
        XCTAssertNil(sut.tableView(tableView, viewForHeaderInSection: 0), "Header não deve retornar view se vazio")
        
        // Case 2: Populated
        let vm = URLShortenerModels.Shorten.ViewModel(
            shortURL: "", originalURL: "",
            history: [.init(original: "A", short: "B", alias: "C")]
        )
        sut.update(state: .success(vm))
        
        XCTAssertEqual(sut.tableView(tableView, heightForHeaderInSection: 0), 40, "Header deve ter altura 40 se houver dados")
        XCTAssertNotNil(sut.tableView(tableView, viewForHeaderInSection: 0), "Header deve retornar view se houver dados")
    }
}

// MARK: - Reflection Helper
// Extensão para acessar subviews privadas da URLShortenerView
extension URLShortenerView {
    
    var urlInputView: URLInputView? {
        return extractElement(name: "urlInputView")
    }
    
    var tableView: UITableView? {
        return extractElement(name: "tableView")
    }
    
    var emptyStateView: UILabel? {
        return extractElement(name: "emptyStateView")
    }
    // REMOVIDO: A função extractElement daqui causava conflito.
    // Usará a implementação da extensão de UIView abaixo.
}

// Helper único para todas as UIViews (SUT e seus filhos)
fileprivate extension UIView {
    func extractElement<T>(name: String) -> T? {
        let mirror = Mirror(reflecting: self)
        let possibilities = [name, "$__lazy_storage_$_\(name)"]
        for key in possibilities {
            if let child = mirror.children.first(where: { $0.label == key }) {
                return child.value as? T
            }
        }
        return nil
    }
}
