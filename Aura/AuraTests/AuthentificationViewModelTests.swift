import XCTest
import Combine
@testable import Aura

// MARK: - Erreur factice pour tests
struct SimulatedError: Error {
    var localizedDescription: String { "Erreur simulée" }
}

final class AuthentificationViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    func makeViewModel(
        onSucceed: @escaping () -> Void = {},
        loginClosure: @escaping (String, String, @escaping (Result<String, Error>) -> Void) -> Void = { _, _, completion in completion(.success("ok_token")) }
    ) -> AuthentificationViewModel {
        AuthentificationViewModel(onLoginSucceed: onSucceed, performLoginRequest: loginClosure)
    }
    
    func testLogin_noToken() {
        let expFailure = expectation(description: "Failure détectée")
        expFailure.isInverted = true // Ne doit PAS être appelé
        
        let vm = makeViewModel(onSucceed: {
            expFailure.fulfill() // Ne pas appeler
        }, loginClosure: { _, _, completion in
            // succès sans token
            let erreur = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Token non trouvé dans la réponse."])
            completion(.failure(erreur))
        })
        
        vm.username = "user@mock.dev"
        vm.password = "pwd"
        vm.login()
        
        wait(for: [expFailure], timeout: 1)
        XCTAssertFalse(vm.isAuthenticated)
    }
    
    
    func testLogin_isAuthAfterSuceed() {
        let expAuth = expectation(description: "isAuthenticated passe à true")
        let vm = makeViewModel(onSucceed: {
            expAuth.fulfill()
        }, loginClosure: { _,_, completion in
            completion(.success("ok"))
        })
        
        vm.username = "user@example.com"
        vm.password = "pass123"
        vm.login()
        
        wait(for: [expAuth], timeout: 1)
        XCTAssertTrue(vm.isAuthenticated)
    }
    
    func testLogin_success_NoError() {
        let expSucceed = expectation(description: "Succès déclenché")
        let vm = makeViewModel(onSucceed: {
            expSucceed.fulfill()
        }, loginClosure: { _, _, completion in
            completion(.success("un token"))
        })
        vm.username = "something"
        vm.password = "password"
        vm.login()
        wait(for: [expSucceed], timeout: 1)
        XCTAssertNil(vm.error)
    }
    
    func testLogin_failed_Error() {
        
        let simulateError = SimulatedError()
        let vm = makeViewModel(loginClosure: { _, _, completion in
            completion(.failure(simulateError))
        })
        
        // On observe le published error
        vm.$error
            .dropFirst()
            .sink { error in
                print("Erreur published : \(String(describing: error))")
                if let error = error, error.message == simulateError.localizedDescription {
                    
                }
            }
            .store(in: &cancellables)
        
        vm.login()
    }
    
    
    
    func testLogin_erreurJSON() {
        let expErreur = expectation(description: "Erreur JSON publiée")
        let vm = makeViewModel(loginClosure: { _, _, completion in
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Erreur JSON"])))
        })
        
        vm.$error
            .dropFirst()
            .sink { error in
                if let error = error, error.message == "Erreur JSON" {
                    expErreur.fulfill()
                }
            }
            .store(in: &cancellables)
        
        vm.login()
        wait(for: [expErreur], timeout: 1)
    }
    
    func testLogin_resetError() {
        let vm = makeViewModel(loginClosure: { _, _, completion in
            completion(.failure(NSError(domain: "", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Erreur 1"
            ])))
        })
        let exp1 = expectation(description: "Erreur n°1 reçue")
        let exp2 = expectation(description: "Erreur n°2 reçue")
        
        vm.$error
            .dropFirst()
            .sink { error in
                if error?.message == "Erreur 1" {
                    exp1.fulfill()
                    // simulate autre tentative
                    vm.performLoginRequest = { _, _, completion in
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [
                            NSLocalizedDescriptionKey: "Erreur 2"
                        ])))
                    }
                    vm.login()
                } else if error?.message == "Erreur 2" {
                    exp2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        vm.username = "test@host.fr"
        vm.password = "passwd"
        vm.login()
        
        wait(for: [exp1, exp2], timeout: 2)
    }
    
    func testLogin_resetErrorBeforeNewRequest() {
        let vm = makeViewModel()
        vm.error = ErrorWr(message: "ancienne erreur")
        
        let exp = expectation(description: "Reset effectué")
        
        vm.$error
            .sink { newError in
                // La première valeur après `.login()` sera nil
                if newError == nil {
                    exp.fulfill()
                }
            }
            .store(in: &cancellables)
        
        vm.login()
        
        wait(for: [exp], timeout: 1)
    }
    
    
    func testLoginClosureRight() {
        // On va capturer les valeurs de user/pass transmises
        let expectedEmail = "nina@flow.com"
        let expectedPass = "lettuce"
        let expAppel = expectation(description: "Closure appelée")
        
        let vm = AuthentificationViewModel(onLoginSucceed: {}, performLoginRequest: { username, password, completion in
            XCTAssertEqual(username, expectedEmail)
            XCTAssertEqual(password, expectedPass)
            expAppel.fulfill()
            completion(.failure(NSError(domain: "", code: 401)))
        })
        
        vm.username = expectedEmail
        vm.password = expectedPass
        vm.login()
        
        wait(for: [expAppel], timeout: 1)
    }
    
    func testLogin_erreurHTTP500ErrorPublished() {
        let expErreur = expectation(description: "Erreur 500 captée")
        let expectedMessage = "Échec de la connexion : Code 500"
        
        let vm = makeViewModel(loginClosure: { _, _, completion in
            completion(.failure(NSError(domain: "", code: 500, userInfo: [
                NSLocalizedDescriptionKey: expectedMessage
            ])))
        })
        
        vm.$error
            .dropFirst()
            .sink { error in
                if let error = error, error.message == expectedMessage {
                    expErreur.fulfill()
                }
            }
            .store(in: &cancellables)
        
        vm.username = "foo@bar"
        vm.password = "baz"
        vm.login()
        
        wait(for: [expErreur], timeout: 1)
    }
    
    
    //Tests email
    func testIsValidEmail_valide() {
        let vm = makeViewModel()
        XCTAssertTrue(vm.isValidEmail("foo@bar.com"))
        XCTAssertTrue(vm.isValidEmail("prenom.nom@entreprise.fr"))
        XCTAssertTrue(vm.isValidEmail("user_123@domaine.co"))
    }
    
    func testIsValidEmail_returnsFalse() {
        let vm = makeViewModel()
        XCTAssertFalse(vm.isValidEmail("test@"))
        XCTAssertFalse(vm.isValidEmail("@gmail.com"))
        XCTAssertFalse(vm.isValidEmail("bob.com"))
        XCTAssertFalse(vm.isValidEmail("alice@local"))
        XCTAssertFalse(vm.isValidEmail(""))
    }
    
    
    
    // MARK: - Injecte un fake, bonne methode ?
    
    
    
    func testDefaultLoginRequest_tokenNotFindGiveErreur() {
        let exp = expectation(description: "Erreur « Token non trouvé » attendue")
        
        // Crée une URL temporairement mauvaise (modifie ApiConfig pour ce test, ou crée une route de test)
        AuthentificationViewModel.defaultLoginRequest(
            username: "john",
            password: "badpass"
        ) { result in
            switch result {
            case .failure(let error as NSError):
                let m = error.userInfo[NSLocalizedDescriptionKey] as? String ?? ""
                // Tous les chemins de defaultLoginRequest sont alors couverts (URL, parsing, HTTP etc.)
                XCTAssertTrue(m.contains("URL invalide") || m.contains("Token non trouvé") || m.contains("Échec de la connexion") || m.contains("Réponse invalide"))
                exp.fulfill()
            case .success:
                XCTFail("Pas de succès attendu avec mauvais params")
            }
        }
        wait(for: [exp], timeout: 3)
    }
    
    func testDefaultLoginRequest_erreurJson() {
        let exp = expectation(description: "Erreur JSON attendue")
        // Username/password invalides pour déclencher une erreur de parsing typique
        AuthentificationViewModel.defaultLoginRequest(
            username: "erruser",
            password: "errpass"
        ) { result in
            switch result {
            case .failure(let error as NSError):
                // Permet de toucher le block de parsing JSON
                let msg = error.userInfo[NSLocalizedDescriptionKey] as? String ?? ""
                XCTAssertTrue(msg.contains("Token non trouvé") || msg.contains("Échec de la connexion") || msg.contains("Réponse invalide"))
                exp.fulfill()
            case .success:
                XCTFail("Ne doit pas réussir avec mauvais credentials")
            }
        }
        wait(for: [exp], timeout: 2)
    }
    
}
