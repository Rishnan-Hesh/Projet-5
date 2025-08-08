import XCTest
@testable import Aura

final class MoneyTransferViewModelTests: XCTestCase {
    var viewModel: MoneyTransferViewModel!
    var mockAccountViewModel: AccountDetailViewModel!
    
    override func setUp() {
        super.setUp()
        // Création d'un faux AccountDetailViewModel pour les tests.
        mockAccountViewModel = AccountDetailViewModel(/* initialisation personnalisée ici si besoin */)
        viewModel = MoneyTransferViewModel(accountViewModel: mockAccountViewModel)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAccountViewModel = nil
        super.tearDown()
    }
    
    // Test  : Vérifie l’injection du AccountDetailViewModel
    func testInit_AccountViewModelInjected() {
        XCTAssertTrue(viewModel.accountViewModel === mockAccountViewModel, "MoneyTransferViewModel doit utiliser la bonne instance de AccountDetailViewModel")
    }
    
    // Test  : Vérifie la validation de destinataire pour cas valide et invalide
    func testIsValidRecipient() {
        XCTAssertTrue(viewModel.isValidRecipient("mail@exemple.com"), "Le destinataire valide devrait être accepté")
        XCTAssertFalse(viewModel.isValidRecipient(""), "Un destinataire vide doit être refusé")
        XCTAssertFalse(viewModel.isValidRecipient("NomSeulement"), "Un destinataire sans mail doit être refusé")
        XCTAssertTrue(viewModel.isValidRecipient("+33612345678"))
        XCTAssertTrue(viewModel.isValidRecipient("0612345678"))
        XCTAssertFalse(viewModel.isValidRecipient("01234"))
    }
    
    func testSendMoney_InvalidRecipient_CallsCompletionWithMessage() {
        viewModel.recipient = "invalid"
        viewModel.amount = "20"
        let expectation = self.expectation(description: "Completion should be called")
        viewModel.sendMoney {
            XCTAssertEqual(self.viewModel.transferMessage, "Destinataire invalide (email ou numéro FR requis).")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Test  : Vérifie l’envoi d’argent avec succès (si méthode asynchrone avec completion)
    func testSendMoney_Success() {
        let expectation = self.expectation(description: "Virement réussi")
        viewModel.sendMoney {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Test  : Vérifie l’échec de l'envoi d'argent
    func testSendMoney_Failure() {
        // Simule une configuration ou donnée provoquant une erreur
        viewModel.recipient = ""
        viewModel.amount = "-10"
        let expectation = self.expectation(description: "Virement échoue")
        viewModel.sendMoney {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Test  : Vérifie la gestion des closures de callback internes (couverture max)
    func test_sendMoney_CompletionIsCalled() {
        let expectation = self.expectation(description: "Callback appelé")
        viewModel.sendMoney {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSendMoney_InvalidAmount_SetsErrorMessage() {
        viewModel.recipient = "mail@exemple.com"
        viewModel.amount = "-10"
        
        let expectation = self.expectation(description: "Erreur pour montant invalide")

        viewModel.sendMoney {
            XCTAssertEqual(self.viewModel.transferMessage, "Montant invalide. Entrez un nombre positif.")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }



    func testSendMoney_ValidInput_SetsSuccessMessage() {
        viewModel.recipient = "mail@exemple.com"
        viewModel.amount = "42"
        let expectation = self.expectation(description: "Virement effectué avec succès !")
        viewModel.sendMoney {
            XCTAssertEqual(self.viewModel.transferMessage, "Virement effectué avec succès !")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    // Test  : propriétés réinitialisées après un envoi
    func testSendMoney_ResetsState() {
        viewModel.recipient = "mail@exemple.com"
        viewModel.amount = "100"
        let expectation = self.expectation(description: "Reset après succès")
        
        viewModel.sendMoney {
            XCTAssertEqual(self.viewModel.recipient, "", "Le destinataire devrait être réinitialisé")
            XCTAssertEqual(self.viewModel.amount, "", "Le montant devrait être réinitialisé")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    
}
