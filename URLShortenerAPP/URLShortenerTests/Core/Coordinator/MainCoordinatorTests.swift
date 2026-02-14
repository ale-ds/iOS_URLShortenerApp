import XCTest
@testable import URLShortener

final class MainCoordinatorTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: MainCoordinator!
    private var navigationControllerSpy: NavigationControllerSpy!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        navigationControllerSpy = NavigationControllerSpy()
        sut = MainCoordinator(navigationController: navigationControllerSpy)
    }
    
    override func tearDown() {
        sut = nil
        navigationControllerSpy = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_init_setsNavigationController() {
        XCTAssertEqual(sut.navigationController, navigationControllerSpy)
    }
    
    func test_start_pushesURLShortenerViewController() {
        // When
        sut.start()
        
        // Then
        XCTAssertTrue(navigationControllerSpy.pushViewControllerCalled)
        XCTAssertTrue(navigationControllerSpy.pushedViewController is URLShortenerViewController)
        XCTAssertFalse(navigationControllerSpy.pushedAnimated) // MainCoordinator calls animated: false
    }
    
    func test_childCoordinators_isEmptyOnInit() {
        XCTAssertTrue(sut.childCoordinators.isEmpty)
    }
}

// MARK: - Test Doubles

final class NavigationControllerSpy: UINavigationController {
    var pushViewControllerCalled = false
    var pushedViewController: UIViewController?
    var pushedAnimated = false
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushViewControllerCalled = true
        pushedViewController = viewController
        pushedAnimated = animated
        super.pushViewController(viewController, animated: animated)
    }
}
