import Foundation

// Structure d'erreur réutilisable, à mettre dans un fichier à part ?
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}

class AuthenticationViewModel: ObservableObject {

    private let networkService: any NetworkService

    #if DEBUG
    @Published var username = "test@aura.app"
    @Published var password = "test123"
    #else
    @Published var username: String = ""
    @Published var password: String = ""
    #endif

    @Published var error: ErrorWrapper? = nil // Gestion des erreurs pour la vue SwiftUI
    
    let onLoginSucceed: (() -> ())
    
    init(networkService: any NetworkService = NetworkServiceImplementation(), onLoginSucceed: @escaping () -> ()) {
        self.networkService = networkService
        self.onLoginSucceed = onLoginSucceed
    }

    func login() async {
        // Vérification de l'adresse e-mail avant requête
        guard isValidEmail(username) else {
            DispatchQueue.main.async {
                self.error = ErrorWrapper(message: "Veuillez entrer une adresse e-mail valide.")
            }
            return
        }
        
        // Setup du backend
        guard let url = ApiConfig.url(for: .auth) else {
            print("URL invalide")
            return
        }
        
        let response: AuthenticationResponse = try! await networkService.call(
            url: url.absoluteString,
            httpMethod: "POST",
            body: try! JSONEncoder().encode(AuthenticationRequest(username: username, password: password))
        )

        print("Token reçu: \(response.token)")
        print(response)

        AuthManager.shared.saveToken(token: response.token)

        DispatchQueue.main.async {
            self.onLoginSucceed()
        }
    }
    
    // Validation d'une adresse e-mail avec une expression régulière
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}

struct AuthenticationRequest: Encodable {
    let username: String
    let password: String
}

struct AuthenticationResponse: Decodable {
    let token: String
}
