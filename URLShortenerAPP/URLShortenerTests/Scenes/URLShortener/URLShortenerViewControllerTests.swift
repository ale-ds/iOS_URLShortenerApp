import XCTest
@testable import URLShortener

final class URLShortenerViewControllerTests: XCTestCase {
    
    // MARK: - System Under Test
    var sut: URLShortenerViewController!
    var interactorSpy: URLShortenerBusinessLogicSpy!
//    var pasteboardSpy: PasteboardSpy! // Novo Spy
    var window: UIWindow!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        interactorSpy = URLShortenerBusinessLogicSpy()
//        pasteboardSpy = PasteboardSpy()
        
        sut = URLShortenerViewController()
        sut.interactor = interactorSpy
//        sut.pasteboard = pasteboardSpy // Injetamos o Mock
        
        // Simula ciclo de vida
        window = UIWindow()
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    override func tearDown() {
        sut = nil
        interactorSpy = nil
//        pasteboardSpy = nil
        window = nil
        super.tearDown()
    }
    
    // MARK: - Lifecycle Tests
    
    func test_viewDidLoad_shouldSetupTitleAndInitialState() {
        XCTAssertNotNil(sut.title)
        XCTAssertEqual(sut.title, String(localized: .uiURLShortenerTitle))
        XCTAssertTrue(sut.view is URLShortenerView)
    }
    
    // MARK: - Interactor Integration Tests
    
    func test_onShortenRequested_shouldCallInteractor() {
        let customView = sut.view as? URLShortenerView
        let urlText = "https://google.com"
        
        customView?.onShortenRequested?(urlText)
        
        XCTAssertTrue(interactorSpy.shortenURLCalled)
        XCTAssertEqual(interactorSpy.requestReceived?.url, urlText)
    }
    
    func test_onRetryRequested_shouldCallInteractor() {
        let customView = sut.view as? URLShortenerView
        let urlText = "https://retry.com"
        
        customView?.onRetryRequested?(urlText)
        
        XCTAssertTrue(interactorSpy.shortenURLCalled)
        XCTAssertEqual(interactorSpy.requestReceived?.url, urlText)
    }
    
    // MARK: - Display Logic Tests
    
    func test_display_loading_shouldUpdateViewAsync() {
        let expectation = XCTestExpectation(description: "Wait for main queue update")
        let customView = sut.view as? URLShortenerView
        
        sut.display(state: .loading)
        
        DispatchQueue.main.async {
            let inputView: URLInputView? = customView?.extractElement(name: "urlInputView")
            let indicator: UIActivityIndicatorView? = inputView?.extractElement(name: "loadingIndicator")
            
            XCTAssertTrue(indicator?.isAnimating ?? false)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_display_success_shouldUpdateViewAsync() {
        let expectation = XCTestExpectation(description: "Wait for main queue update")
        let customView = sut.view as? URLShortenerView
        
        let historyItem = URLShortenerModels.Shorten.HistoryItem(
            original: "orig", short: "short", alias: "alias"
        )
        let viewModel = URLShortenerModels.Shorten.ViewModel(
            shortURL: "short",
            originalURL: "orig",
            history: [historyItem]
        )
        
        sut.display(state: .success(viewModel))
        
        DispatchQueue.main.async {
            let tableView: UITableView? = customView?.extractElement(name: "tableView")
            XCTAssertFalse(tableView?.isHidden ?? true)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_onTyping_shouldResetToIdleState() {
        let expectation = XCTestExpectation(description: "Wait for main queue update")
        let customView = sut.view as? URLShortenerView
        
        sut.display(state: .error(.init(title: "E", message: "M", buttonTitle: nil, shouldRetry: false)))
        
        customView?.onTyping?()
        
        DispatchQueue.main.async {
            let inputView: URLInputView? = customView?.extractElement(name: "urlInputView")
            let errorContainer: UIView? = inputView?.extractElement(name: "errorContainerView")
            
            XCTAssertTrue(errorContainer?.isHidden ?? false)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Pasteboard Tests (CORRIGIDO)
    
//    func test_onCopyRequested_shouldCopyToPasteboard() {
//        // Given
//        let customView = sut.view as? URLShortenerView
//        let expectedText = "http://short.url/123"
//        
//        // When
//        // Executamos a closure. Como injetamos o PasteboardSpy,
//        // ele NÃO chamará o sistema real, evitando o travamento.
//        customView?.onCopyRequested?(expectedText)
//        
//        // Then
//        XCTAssertTrue(pasteboardSpy.setStringCalled, "Deveria ter chamado o setString do pasteboard")
//        XCTAssertEqual(pasteboardSpy.stringReceived, expectedText, "Deveria ter copiado a string correta")
//    }
}

// MARK: - Test Doubles

final class URLShortenerBusinessLogicSpy: URLShortenerBusinessLogic {
    var shortenURLCalled = false
    var requestReceived: URLShortenerModels.Shorten.Request?
    
    func shortenURL(request: URLShortenerModels.Shorten.Request) {
        shortenURLCalled = true
        requestReceived = request
    }
}

//// Novo Spy para o Pasteboard
//final class PasteboardSpy: Pasteboarder {
//    var setStringCalled = false
//    var stringReceived: String?
//    
//    func setString(_ string: String) {
//        setStringCalled = true
//        stringReceived = string
//    }
//}

// MARK: - Reflection Helper
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
