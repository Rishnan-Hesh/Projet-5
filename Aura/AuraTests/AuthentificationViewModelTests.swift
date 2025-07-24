import XCTest
@testable import Aura

final class AuthenticationViewModelTests: XCTestCase {
    func testLogin_withInvalidEmail_setsError() {
        // 1. Préparer une expectation asynchrone pour attendre la modification de l'erreur.
        let expectation = self.expectation(description: "Erreur d'email détectée")

        // 2. Crée un AuthenticationViewModel avec un closure factice (ne rien faire sur succès).
        let viewModel = AuthenticationViewModel(onLoginSucceed: { })

        // 3. Surveille la propriété error (published), en utilisant Combine si version iOS >= 13.
        var cancellable: Any?
        cancellable = viewModel.$error.sink { errorValue in
            if let errorValue = errorValue {
                // 4. Vérifie que le message correspond à celui attendu
                XCTAssertEqual(errorValue.message, "Veuillez entrer une adresse e-mail valide.")
                expectation.fulfill()
                cancellable = nil // Stoppe l'observation une fois reçu
            }
        }

        // 5. Remplit le champ avec un email invalide et un mot de passe factice
        viewModel.username = "notanemail"
        viewModel.password = "any"

        // 6. Appelle la méthode login (devrait échouer et remplir l'erreur)
        viewModel.login()

        // 7. Attend le résultat max 2 secondes
        wait(for: [expectation], timeout: 2.0)
    }
}

