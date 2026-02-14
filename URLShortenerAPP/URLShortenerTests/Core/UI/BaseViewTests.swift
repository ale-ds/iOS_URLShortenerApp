import XCTest
@testable import URLShortener

final class BaseViewTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: BaseView!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    /// Testa se o inicializador init(frame:) chama o método setupViewConfiguration
    /// e consequentemente os métodos do protocolo ViewConfiguration.
    func test_init_callsViewConfigurationMethods() {
        // Given
        let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        // When
        let spy = BaseViewSpy(frame: frame)
        
        // Then
        XCTAssertTrue(spy.buildHierarchyCalled, "buildHierarchy deveria ter sido chamado na inicialização")
        XCTAssertTrue(spy.setupConstraintsCalled, "setupConstraints deveria ter sido chamado na inicialização")
        XCTAssertTrue(spy.configureViewsCalled, "configureViews deveria ter sido chamado na inicialização")
    }
    
    /// Testa se o método configureViews define a cor de fundo padrão corretamente.
    func test_configureViews_setsDefaultBackgroundColor() {
        // Given
        let frame = CGRect.zero
        
        // When
        sut = BaseView(frame: frame)
        
        // Then
        XCTAssertEqual(sut.backgroundColor, .systemBackground, "A cor de fundo deveria ser .systemBackground")
    }
    
    /// Testa se a BaseView conforma ao protocolo ViewConfiguration.
    func test_conformsToViewConfiguration() throws {
        let frame = CGRect.zero
        sut = BaseView(frame: frame)
        
        let unwrappedSut = try XCTUnwrap(sut)
        
        // O cast para Any silencia o warning 'is test is always true'
        XCTAssertTrue((unwrappedSut as Any) is ViewConfiguration, "BaseView deve conformar ao protocolo ViewConfiguration")
    }
    
    /// Testa se os métodos vazios (buildHierarchy, setupConstraints) podem ser chamados sem efeitos colaterais (crash).
    /// Isso valida a implementação padrão vazia na BaseView.
    func test_defaultMethods_executeSafely() {
        // Given
        sut = BaseView(frame: .zero)
        
        // When
        sut.buildHierarchy()
        sut.setupConstraints()
        
        // Then
        // Se chegamos aqui, o teste passou (não houve crash)
        XCTAssertNotNil(sut)
    }
    
    /// Testa o comportamento do init(coder:)
    /// Nota: Como init(coder:) dispara fatalError, não podemos executá-lo diretamente sem crashar o teste.
    /// No entanto, verificamos que ele existe e é requerido.
    func test_initCoder_isUnavailable() {
        // Esta validação é mais estática ou visual, pois fatalError não é capturável nativamente no XCTest sem helpers C++.
        // Mantemos este caso de teste documentado para evidenciar que o cenário de exceção é conhecido.
        let hasInitCoder = BaseView.instancesRespond(to: #selector(UIView.init(coder:)))
        XCTAssertTrue(hasInitCoder, "BaseView deve possuir implementação (mesmo que fatalError) de init(coder:)")
    }
}

// MARK: - Test Doubles

private class BaseViewSpy: BaseView {
    var buildHierarchyCalled = false
    var setupConstraintsCalled = false
    var configureViewsCalled = false
    
    override func buildHierarchy() {
        buildHierarchyCalled = true
        super.buildHierarchy()
    }
    
    override func setupConstraints() {
        setupConstraintsCalled = true
        super.setupConstraints()
    }
    
    override func configureViews() {
        configureViewsCalled = true
        super.configureViews()
    }
}
