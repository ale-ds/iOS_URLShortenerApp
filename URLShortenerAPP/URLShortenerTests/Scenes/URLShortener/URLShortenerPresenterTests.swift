import XCTest
@testable import URLShortener

final class URLShortenerPresenterTests: XCTestCase {
    
    // MARK: - System Under Test (SUT)
    var sut: URLShortenerPresenter!
    var viewControllerSpy: URLShortenerDisplayLogicSpy!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        viewControllerSpy = URLShortenerDisplayLogicSpy()
        sut = URLShortenerPresenter()
        sut.viewController = viewControllerSpy
    }
    
    override func tearDown() {
        sut = nil
        viewControllerSpy = nil
        super.tearDown()
    }
    
    // MARK: - Success Tests
    
    func testPresentShortenedURL_ShouldFormatDataCorrectly() {
        // Given
        let shortenedURL = ShortenedURL(
            alias: "123",
            originalURL: "http://google.com",
            shortURL: "http://short.com/123"
        )
        let history = [shortenedURL]
        let response = URLShortenerModels.Shorten.Response(
            shortenedURL: shortenedURL,
            history: history
        )
        
        // When
        sut.presentShortenedURL(response: response)
        
        // Then
        XCTAssertTrue(viewControllerSpy.displayCalled)
        
        guard let state = viewControllerSpy.displayState,
              case .success(let viewModel) = state else {
            XCTFail("Deveria estar no estado .success")
            return
        }
        
        XCTAssertEqual(viewModel.shortURL, "http://short.com/123")
        XCTAssertEqual(viewModel.history.count, 1)
        XCTAssertEqual(viewModel.history.first?.alias, "123")
    }
    
    func testPresentLoading_ShouldDisplayLoadingState() {
        // When
        sut.presentLoading()
        
        // Then
        XCTAssertTrue(viewControllerSpy.displayCalled)
        
        guard let state = viewControllerSpy.displayState,
              case .loading = state else {
            XCTFail("Deveria estar no estado .loading")
            return
        }
    }
    
    // MARK: - Error Logic Tests (Retry Button)
    
    func testPresentError_WhenTimeout_ShouldShowRetryButton() {
        // Given
        let error = NetworkError.timeout // Erro recuperável
        let response = URLShortenerModels.Error.Response(error: error)
        
        // When
        sut.presentError(response: response)
        
        // Then
        guard let state = viewControllerSpy.displayState,
              case .error(let viewModel) = state else {
            XCTFail("Deveria estar no estado .error")
            return
        }
        
        XCTAssertTrue(viewModel.shouldRetry, "Timeout deve permitir retry")
        XCTAssertNotNil(viewModel.buttonTitle)
    }
    
    func testPresentError_WhenNoConnectivity_ShouldShowRetryButton() {
        // Given
        let error = NetworkError.noConnectivity // Erro recuperável
        let response = URLShortenerModels.Error.Response(error: error)
        
        // When
        sut.presentError(response: response)
        
        // Then
        guard let state = viewControllerSpy.displayState,
              case .error(let viewModel) = state else {
            XCTFail("Deveria estar no estado .error")
            return
        }
        
        XCTAssertTrue(viewModel.shouldRetry, "Sem conexão deve permitir retry")
    }
    
    func testPresentError_WhenDomainError_ShouldHideRetryButton() {
        // Given
        let error = DomainError.invalidURL // Erro de negócio (não adianta tentar de novo)
        let response = URLShortenerModels.Error.Response(error: error)
        
        // When
        sut.presentError(response: response)
        
        // Then
        guard let state = viewControllerSpy.displayState,
              case .error(let viewModel) = state else {
            XCTFail("Deveria estar no estado .error")
            return
        }
        
        XCTAssertFalse(viewModel.shouldRetry, "Erro de domínio NÃO deve permitir retry")
    }
}
