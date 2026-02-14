import XCTest
@testable import URLShortener

final class URLInputViewTests: XCTestCase {
    
    // MARK: - System Under Test
    var sut: URLInputView!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        sut = URLInputView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        sut.layoutIfNeeded() // Garanta que lazy vars sejam carregadas
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Interaction Tests
    
    func test_didTapAction_whenTextIsValid_shouldTriggerOnShorten() throws {
        // Given
        let textField = try XCTUnwrap(sut.textField)
        let button = try XCTUnwrap(sut.actionButton)
        
        textField.text = "https://google.com"
        
        var capturedURL: String?
        sut.onShorten = { url in
            capturedURL = url
        }
        
        // When
        button.sendActions(for: .touchUpInside)
        
        // Then
        XCTAssertEqual(capturedURL, "https://google.com")
    }
    
    func test_didTapAction_whenTextIsEmpty_shouldNotTriggerOnShorten() throws {
        // Given
        let textField = try XCTUnwrap(sut.textField)
        let button = try XCTUnwrap(sut.actionButton)
        
        textField.text = "" // Vazio
        
        var capturedURL: String?
        sut.onShorten = { url in
            capturedURL = url
        }
        
        // When
        button.sendActions(for: .touchUpInside)
        
        // Then
        XCTAssertNil(capturedURL, "Não deve disparar evento se o texto estiver vazio")
    }
    
    func test_didTapRetry_shouldTriggerOnRetryWithCurrentText() throws {
        // Given
        let textField = try XCTUnwrap(sut.textField)
        let retryBtn = try XCTUnwrap(sut.retryButton)
        
        let urlString = "https://fail.com"
        textField.text = urlString
        
        var capturedURL: String?
        sut.onRetry = { url in
            capturedURL = url
        }
        
        // When
        retryBtn.sendActions(for: .touchUpInside)
        
        // Then
        XCTAssertEqual(capturedURL, urlString)
    }
    
    func test_typing_shouldTriggerOnTypingClosure() throws {
        // Given
        let textField = try XCTUnwrap(sut.textField)
        
        var typingTriggered = false
        sut.onTyping = { typingTriggered = true }
        
        // When
        // Simula digitação via Delegate
        _ = sut.textField(textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "A")
        
        // Then
        XCTAssertTrue(typingTriggered)
    }
    
    func test_returnKey_shouldTriggerAction() throws {
        // Given
        let textField = try XCTUnwrap(sut.textField)
        textField.text = "return.key.com"
        
        var capturedURL: String?
        sut.onShorten = { url in capturedURL = url }
        
        // When
        _ = sut.textFieldShouldReturn(textField)
        
        // Then
        XCTAssertEqual(capturedURL, "return.key.com")
    }
    
    // MARK: - State Tests
    
    func test_update_loading_shouldUpdateUI() throws {
        // Given
        let loadingIndicator = try XCTUnwrap(sut.loadingIndicator)
        let actionButton = try XCTUnwrap(sut.actionButton)
        let textField = try XCTUnwrap(sut.textField)
        
        // When
        sut.update(state: .loading)
        
        // Then
        XCTAssertTrue(loadingIndicator.isAnimating, "Spinner deve estar animando")
        XCTAssertTrue(actionButton.isHidden, "Botão de ação deve esconder no loading")
        XCTAssertFalse(textField.isEnabled, "TextField deve desabilitar no loading")
        XCTAssertTrue(try XCTUnwrap(sut.errorContainerView).isHidden, "Erro deve sumir no loading")
    }
    
    func test_update_error_withRetry_shouldShowErrorUI() throws {
        // Given
        let errorVM = ErrorViewModel(
            title: "Ops",
            message: "Erro de conexão",
            buttonTitle: "Tentar",
            shouldRetry: true
        )
        
        let errorContainer = try XCTUnwrap(sut.errorContainerView)
        let retryButton = try XCTUnwrap(sut.retryButton)
        let errorLabel = try XCTUnwrap(sut.errorLabel)
        let inputContainer = try XCTUnwrap(sut.inputContainerView)
        
        // When
        sut.update(state: .error(errorVM))
        
        // Then
        XCTAssertFalse(errorContainer.isHidden, "Container de erro deve aparecer")
        XCTAssertEqual(errorLabel.text, "Erro de conexão")
        XCTAssertFalse(retryButton.isHidden, "Botão de retry deve aparecer")
        XCTAssertEqual(inputContainer.layer.borderWidth, 1, "Deve ter borda vermelha")
        XCTAssertEqual(inputContainer.layer.borderColor, UIColor.systemRed.cgColor)
        
        // Valida que saiu do estado de loading
        let loadingIndicator = try XCTUnwrap(sut.loadingIndicator)
        XCTAssertFalse(loadingIndicator.isAnimating)
    }
    
    func test_update_error_withoutRetry_shouldHideRetryButton() throws {
        // Given
        let errorVM = ErrorViewModel(
            title: "Erro",
            message: "URL Inválida",
            buttonTitle: nil,
            shouldRetry: false
        )
        
        let retryButton = try XCTUnwrap(sut.retryButton)
        
        // When
        sut.update(state: .error(errorVM))
        
        // Then
        XCTAssertTrue(retryButton.isHidden, "Botão de retry deve estar oculto")
        XCTAssertFalse(try XCTUnwrap(sut.errorContainerView).isHidden, "Mensagem de erro ainda deve aparecer")
    }
    
    func test_update_success_shouldResetUI() throws {
        // Given
        let textField = try XCTUnwrap(sut.textField)
        textField.text = "Texto Antigo"
        
        // Configura estado de erro prévio para garantir que limpa
        let errorVM = ErrorViewModel(title: "E", message: "M", buttonTitle: "B", shouldRetry: true)
        sut.update(state: .error(errorVM))
        
        // Dummy Success ViewModel
        let successVM = URLShortenerModels.Shorten.ViewModel(
            shortURL: "short",
            originalURL: "orig",
            history: []
        )
        
        // When
        sut.update(state: .success(successVM))
        
        // Then
        XCTAssertEqual(textField.text, "", "Deve limpar o input no sucesso")
        XCTAssertTrue(try XCTUnwrap(sut.errorContainerView).isHidden, "Deve esconder erro")
        XCTAssertEqual(try XCTUnwrap(sut.inputContainerView).layer.borderWidth, 0, "Deve remover borda vermelha")
    }
}

// MARK: - Reflection Helper
// Permite acessar views privadas (@testable não acessa private, apenas internal)
extension URLInputView {
    
    var textField: UITextField? { extractElement(name: "textField") }
    var actionButton: UIButton? { extractElement(name: "actionButton") }
    var loadingIndicator: UIActivityIndicatorView? { extractElement(name: "loadingIndicator") }
    var errorContainerView: UIView? { extractElement(name: "errorContainerView") }
    var errorLabel: UILabel? { extractElement(name: "errorLabel") }
    var retryButton: UIButton? { extractElement(name: "retryButton") }
    var inputContainerView: UIView? { extractElement(name: "inputContainerView") }
    
    private func extractElement<T>(name: String) -> T? {
        let mirror = Mirror(reflecting: self)
        
        // Tenta encontrar a propriedade direta ou a backing storage do lazy var
        let possibilities = [name, "$__lazy_storage_$_\(name)"]
        
        for key in possibilities {
            if let child = mirror.children.first(where: { $0.label == key }) {
                // Se for lazy, o valor pode estar dentro de um Optional aninhado
                return child.value as? T
            }
        }
        return nil
    }
}
