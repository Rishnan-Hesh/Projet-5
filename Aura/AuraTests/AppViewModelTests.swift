import XCTest
@testable import Aura

final class AppViewModelTests: XCTestCase {
    var viewModel: AppViewModel!

    override func setUp() {
        super.setUp()
        viewModel = AppViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testIsLogged_DefaultValue() {
        XCTAssertFalse(viewModel.isLogged)
    }

    func testOnLoginSucceed_SetsIsLogged() {
        viewModel.authentificationViewModel.onLoginSucceed()
        XCTAssertTrue(viewModel.isLogged)
    }

    func testOnLoginSucceed_Idempotence() {
        viewModel.authentificationViewModel.onLoginSucceed()
        viewModel.authentificationViewModel.onLoginSucceed()
        XCTAssertTrue(viewModel.isLogged)
    }

    func testAllViewModels_AreNotNil() {
        XCTAssertNotNil(viewModel.accountDetailViewModel)
        XCTAssertNotNil(viewModel.moneyTransferViewModel)
        XCTAssertNotNil(viewModel.authentificationViewModel)
    }

    func testMoneyTransferViewModel_UsesInjectedAccountDetailViewModel() {
        let moneyTransferVM = viewModel.moneyTransferViewModel
        XCTAssertTrue(moneyTransferVM.accountViewModel === viewModel.accountDetailViewModel)
    }
}
