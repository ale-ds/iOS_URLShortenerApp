import XCTest
@testable import URLShortener

// MARK: - UseCase Spy
final class ShortenURLUseCaseSpy: ShortenURLUseCaseProtocol {
    
    var executeCalled = false
    var executeCallCount = 0
    
    // O que o Spy deve retornar
    var resultToReturn: Result<ShortenedURL, Error>?
    // Lista de resultados para simular falha -> sucesso (Retry)
    var sequentialResults: [Result<ShortenedURL, Error>] = []
    
    func execute(url: String) async throws -> ShortenedURL {
        executeCalled = true
        executeCallCount += 1
        
        // Se tivermos uma sequência configurada, usamos ela
        if !sequentialResults.isEmpty {
            let result = sequentialResults.removeFirst()
            switch result {
            case .success(let data): return data
            case .failure(let error): throw error
            }
        }
        
        // Caso contrário, usamos o resultado único fixo
        guard let result = resultToReturn else {
            throw DomainError.invalidURL // Default de segurança
        }
        
        switch result {
        case .success(let data): return data
        case .failure(let error): throw error
        }
    }
}

// MARK: - Presentation Logic Spy
final class URLShortenerPresentationLogicSpy: URLShortenerPresentationLogic {
    
    // Flags para verificar chamadas
    var presentLoadingCalled = false
    var presentShortenedURLCalled = false
    var presentErrorCalled = false
    
    // Dados capturados para asserção
    var presentShortenedURLResponse: URLShortenerModels.Shorten.Response?
    var presentErrorResponse: URLShortenerModels.Error.Response?
    
    // Expectativas para testes assíncronos (Avisa o teste quando o método é chamado)
    var expectation: XCTestExpectation?
    
    func presentLoading() {
        presentLoadingCalled = true
    }
    
    func presentShortenedURL(response: URLShortenerModels.Shorten.Response) {
        presentShortenedURLCalled = true
        presentShortenedURLResponse = response
        expectation?.fulfill()
    }
    
    func presentError(response: URLShortenerModels.Error.Response) {
        presentErrorCalled = true
        presentErrorResponse = response
        expectation?.fulfill()
    }
}

// MARK: - Display Logic Spy
final class URLShortenerDisplayLogicSpy: URLShortenerDisplayLogic {
    
    var displayCalled = false
    var displayState: ViewState<URLShortenerModels.Shorten.ViewModel>?
    
    func display(state: ViewState<URLShortenerModels.Shorten.ViewModel>) {
        displayCalled = true
        displayState = state
    }
}
