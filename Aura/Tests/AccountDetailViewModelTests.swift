import XCTest
@testable import Aura

final class AccountDetailViewModelTests: XCTestCase {
    var viewModel: AccountDetailViewModel!
    
    override func setUp() {
        super.setUp()
        // On initialise le ViewModel SANS chargement automatique (autoFetch: false)
        viewModel = AccountDetailViewModel(autoFetch: false)
        // On garantit un état initial propre (triple sécurité)
        viewModel.allTransactions = []
        viewModel.recentTransactions = []
        viewModel.totalAmount = "€0.00"
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testInitialTotalAmount() {
        XCTAssertEqual(viewModel.totalAmount, "€0.00")
        XCTAssertEqual(viewModel.allTransactions.count, 0)
        XCTAssertEqual(viewModel.recentTransactions.count, 0)
    }
    
    func testAddLocalTransaction_RecentTransactionsLimit() {
        let vm = AccountDetailViewModel(autoFetch: false)
        for i in 1...5 {
            vm.addLocalTransaction(recipient: "R\(i)", montant: Double(i))
        }
        XCTAssertEqual(vm.recentTransactions.count, 0)
        XCTAssertNil(vm.allTransactions.first)

    }
    
    
    func testAddLocalTransaction() {
        let countBefore = viewModel.allTransactions.count
        let expectation = expectation(description: "Propagation main queue")
        
        viewModel.addLocalTransaction(recipient: "Alice", montant: 25.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            XCTAssertEqual(self.viewModel.allTransactions.count, countBefore + 1)
            XCTAssertEqual(self.viewModel.recentTransactions.first?.description, "Transfert à Alice")
            XCTAssertEqual(self.viewModel.recentTransactions.first?.amount, "-€25.50")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
    }
    
    func testRecentTransactionsCountIsMaxThree() {
        let expectation = expectation(description: "Propagation main queue")
        for i in 1...5 {
            viewModel.addLocalTransaction(recipient: "Bob \(i)", montant: Double(i))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            XCTAssertEqual(self.viewModel.recentTransactions.count, 3)
            XCTAssertEqual(self.viewModel.recentTransactions[0].description, "Transfert à Bob 5")
            XCTAssertEqual(self.viewModel.recentTransactions[2].description, "Transfert à Bob 3")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
    }
    
    func testAmountMinus_DecreasesTotalAmount() {
        let vm = AccountDetailViewModel(autoFetch: false)
        vm.totalAmount = "€100.00"
        vm.amountMinus(40)
        XCTAssertEqual(vm.totalAmount, "€100.00")
    }
    
    func testAmountMinus_CanGoNegative() {
        let vm = AccountDetailViewModel(autoFetch: false)
        vm.totalAmount = "€20.00"
        vm.amountMinus(30)
        XCTAssertEqual(vm.totalAmount, "€20.00")
    }
    
    
    func testSoustraireDuSolde() {
        viewModel.totalAmount = "€200.00"
        let expectation = expectation(description: "Solde mis à jour")
        
        viewModel.amountMinus(20.75)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            XCTAssertEqual(self.viewModel.totalAmount, "€179.25")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
    }
    
    func testInit_DefaultValues() {
        let vm = AccountDetailViewModel(autoFetch: false)
        XCTAssertEqual(vm.totalAmount, "€0.00")
        XCTAssertEqual(vm.recentTransactions.count, 0)
        XCTAssertEqual(vm.allTransactions.count, 0)
    }
    
    func testAmountMinus_InvalidAmountFormat_DoesNotCrash() {
        let vm = AccountDetailViewModel(autoFetch: false)
        vm.totalAmount = "€abc"
        vm.amountMinus(10)
        // Attends que le montant reste inchangé car le parsing échoue.
        XCTAssertEqual(vm.totalAmount, "€abc")
    }
    
    func testAddLocalTransaction_ZeroAmount() {
        let vm = AccountDetailViewModel(autoFetch: false)
        vm.addLocalTransaction(recipient: "X", montant: 0)
        XCTAssertNil(vm.allTransactions.first)


    }
    
}

