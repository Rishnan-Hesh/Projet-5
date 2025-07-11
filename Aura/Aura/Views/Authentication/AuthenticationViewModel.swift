import Foundation

// Structure d'erreur réutilisable, à mettre dans un fichier à part ?
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}

class AuthenticationViewModel: ObservableObject {

    #if DEBUG
    @Published var username = "test@aura.app"
    @Published var password = "test123"
    #else
    @Published var username = ""
    @Published var password = ""
    #endif

    @Published var error: ErrorWrapper? = nil // Gestion des erreurs pour la vue SwiftUI

    let networkService: NetworkService

    let onLoginSucceed: (() -> Void)

    init(networkService: NetworkService = NetworkService(), _ callback: @escaping () -> ()) {
        self.networkService = networkService
        self.onLoginSucceed = callback
    }

    @MainActor
    func login() async {
        // Vérification de l'adresse e-mail avant requête
        guard isValidEmail(username) else {
            error = ErrorWrapper(message: "Veuillez entrer une adresse e-mail valide.")
            return
        }

        do {
            try await networkService.authenticate(username: username, password: password)
        } catch {
            // TODO: handle network service error
        }
    }
    
    // Validation d'une adresse e-mail avec une expression régulière
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}
