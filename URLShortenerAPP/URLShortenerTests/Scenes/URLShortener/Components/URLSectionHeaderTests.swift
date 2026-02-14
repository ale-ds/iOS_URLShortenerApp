import XCTest
@testable import URLShortener

final class URLSectionHeaderTests: XCTestCase {
    
    // MARK: - System Under Test
    var sut: URLSectionHeader!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        sut = URLSectionHeader(reuseIdentifier: URLSectionHeader.identifier)
        // Força o ciclo de layout para garantir que lazy vars e constraints sejam processadas
        sut.layoutIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_init_shouldAddTitleLabelToContentView() throws {
        // Given / When (init já executado no setUp)
        
        // Then
        let label = try XCTUnwrap(sut.titleLabel)
        XCTAssertTrue(label.isDescendant(of: sut.contentView), "O label deve estar dentro da contentView")
    }
    
    func test_configure_shouldSetCorrectStyleProperties() throws {
        // Given
        let label = try XCTUnwrap(sut.titleLabel)
        
        // Then
        // Fonte: System 13 Bold
        XCTAssertEqual(label.font, .systemFont(ofSize: 13, weight: .bold), "A fonte deve ser System 13 Bold")
        
        // Cor do texto
        XCTAssertEqual(label.textColor, .secondaryLabel, "A cor do texto deve ser secondaryLabel")
        
        // Background da Header
        XCTAssertEqual(sut.contentView.backgroundColor, .systemBackground, "O background deve ser systemBackground")
    }
    
    func test_configure_shouldSetLocalizedText() throws {
        // Given
        let label = try XCTUnwrap(sut.titleLabel)
        
        // When (init)
        
        // Then
        // Verifica apenas se o texto não está nil ou vazio,
        // pois o valor exato depende da chave de localização no Bundle.
        XCTAssertNotNil(label.text)
        XCTAssertFalse(label.text?.isEmpty ?? true, "O título deve ter um texto definido")
    }
    
    func test_reuseIdentifier_shouldBeCorrect() {
        XCTAssertEqual(URLSectionHeader.identifier, "URLSectionHeader", "O identifier estático deve estar correto")
        XCTAssertEqual(sut.reuseIdentifier, "URLSectionHeader", "O reuseIdentifier da instância deve ser repassado corretamente")
    }
}

// MARK: - Reflection Helper
extension URLSectionHeader {
    
    var titleLabel: UILabel? {
        return extractElement(name: "titleLabel")
    }
    
    private func extractElement<T>(name: String) -> T? {
        let mirror = Mirror(reflecting: self)
        
        // Busca direta ou via lazy storage
        let possibilities = [name, "$__lazy_storage_$_\(name)"]
        
        for key in possibilities {
            if let child = mirror.children.first(where: { $0.label == key }) {
                return child.value as? T
            }
        }
        return nil
    }
}
