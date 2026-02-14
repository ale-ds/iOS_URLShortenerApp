import XCTest
@testable import URLShortener

final class URLShortenerInteractorTests: XCTestCase {
    
    // MARK: - System Under Test (SUT) & Doubles
    var sut: URLShortenerInteractor!
    var useCaseSpy: ShortenURLUseCaseSpy!
    var presenterSpy: URLShortenerPresentationLogicSpy!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        useCaseSpy = ShortenURLUseCaseSpy()
        presenterSpy = URLShortenerPresentationLogicSpy()
        sut = URLShortenerInteractor(useCase: useCaseSpy)
        sut.presenter = presenterSpy
    }
    
    override func tearDown() {
        sut = nil
        useCaseSpy = nil
        presenterSpy = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testShortenURL_WhenSuccess_ShouldPresentShortenedURL() {
        // Given
        let expectedURL = ShortenedURL(
            alias: "123",
            originalURL: "http://google.com",
            shortURL: "http://short.com/123"
        )
        useCaseSpy.resultToReturn = .success(expectedURL)
        
        let request = URLShortenerModels.Shorten.Request(
            url: "http://google.com"
        )
        
        // Expectation: O Interactor roda em Task {}, precisamos esperar a resposta chegar no Presenter
        let expectation = XCTestExpectation(
            description: "Wait for presenter"
        )
        presenterSpy.expectation = expectation
        
        // When
        sut.shortenURL(request: request)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(presenterSpy.presentLoadingCalled, "Deve apresentar loading inicial")
        XCTAssertTrue(useCaseSpy.executeCalled, "Deve chamar o UseCase")
        XCTAssertEqual(useCaseSpy.executeCallCount, 1, "Deve chamar o UseCase apenas 1 vez")
        
        XCTAssertTrue(presenterSpy.presentShortenedURLCalled, "Deve apresentar sucesso")
        XCTAssertEqual(presenterSpy.presentShortenedURLResponse?.shortenedURL, expectedURL)
        
        // Verifica se salvou no histórico (DataStore)
        XCTAssertEqual(sut.history.count, 1)
        XCTAssertEqual(sut.history.first, expectedURL)
    }
    
    func testShortenURL_WhenDomainError_ShouldNotRetryAndPresentError() {
        // Given
        // Erro de domínio (ex: URL inválida) NÃO deve acionar o Retry
        useCaseSpy.resultToReturn = .failure(DomainError.invalidURL)
        
        let request = URLShortenerModels.Shorten.Request(url: "invalid-url")
        
        let expectation = XCTestExpectation(description: "Wait for presenter error")
        presenterSpy.expectation = expectation
        
        // When
        sut.shortenURL(request: request)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(presenterSpy.presentLoadingCalled)
        XCTAssertTrue(useCaseSpy.executeCalled)
        XCTAssertEqual(useCaseSpy.executeCallCount, 1, "NÃO deve tentar novamente para erros de domínio")
        
        XCTAssertTrue(presenterSpy.presentErrorCalled, "Deve apresentar erro")
        XCTAssertTrue(presenterSpy.presentErrorResponse?.error is DomainError)
    }
    
    func testShortenURL_WhenNetworkError_ShouldRetryAndEventuallyFail() {
        // Given
        // Timeout deve acionar o mecanismo de Retry
        useCaseSpy.resultToReturn = .failure(NetworkError.timeout)
        
        let request = URLShortenerModels.Shorten.Request(
            url: "http://google.com"
        )
        
        let expectation = XCTestExpectation(description: "Wait for retries")
        presenterSpy.expectation = expectation
        
        // When
        sut.shortenURL(request: request)
        
        // Then
        // O tempo de timeout é alto aqui (3s+) pois o Interactor tem sleep real de 1s + 2s
        wait(for: [expectation], timeout: 4.0)
        
        // Lógica: 1 tentativa inicial + 2 retries (maxRetries = 2) = 3 chamadas totais
        XCTAssertEqual(useCaseSpy.executeCallCount, 3, "Deve tentar 3 vezes (1 inicial + 2 retries)")
        
        XCTAssertTrue(presenterSpy.presentErrorCalled, "Deve apresentar erro ao final das tentativas")
        XCTAssertTrue(presenterSpy.presentErrorResponse?.error is NetworkError)
    }
    
    func testShortenURL_WhenNetworkErrorRecovered_ShouldRetryAndSucceed() {
        // Given
        let expectedURL = ShortenedURL(
            alias: "rec",
            originalURL: "http://rec.com",
            shortURL: "http://s.com/rec"
        )
        
        // Configura sequência: 1ª Falha (Timeout) -> 2ª Sucesso
        useCaseSpy.sequentialResults = [
            .failure(NetworkError.timeout),
            .success(expectedURL)
        ]
        
        let request = URLShortenerModels.Shorten.Request(url: "http://rec.com")
        
        let expectation = XCTestExpectation(description: "Wait for recovery")
        presenterSpy.expectation = expectation
        
        // When
        sut.shortenURL(request: request)
        
        // Then
        // Esperamos 2 segundos para garantir o sleep da primeira tentativa
        wait(for: [expectation], timeout: 2.5)
        
        XCTAssertEqual(useCaseSpy.executeCallCount, 2, "Deve ter chamado 2 vezes (1 falha + 1 sucesso)")
        XCTAssertTrue(presenterSpy.presentShortenedURLCalled, "Deve apresentar sucesso no final")
        XCTAssertEqual(presenterSpy.presentShortenedURLResponse?.shortenedURL, expectedURL)
    }
}
