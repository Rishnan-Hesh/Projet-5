import Foundation

// Structure d'erreur réutilisable, à mettre dans un fichier à part ?
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}

class AuthenticationViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var error: ErrorWrapper? = nil // Gestion des erreurs pour la vue SwiftUI
    
    let onLoginSucceed: (() -> ())
    
    init(_ callback: @escaping () -> ()) {
        self.onLoginSucceed = callback
    }
    
    func login() {
        // Vérification de l'adresse e-mail avant requête
        guard isValidEmail(username) else {
            DispatchQueue.main.async {
                self.error = ErrorWrapper(message: "Veuillez entrer une adresse e-mail valide.")
            }
            return
        }
        
        // Setup du backend
        guard let url = URL(string: "http://127.0.0.1:8080/auth") else {
            print("URL invalide")
            return
        }
        
        let body: [String: String] = [
            "username": username,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Erreur de conversion JSON")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erreur réseau: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.error = ErrorWrapper(message: "Erreur réseau : \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Réponse invalide")
                DispatchQueue.main.async {
                    self.error = ErrorWrapper(message: "Réponse invalide du serveur.")
                }
                return
            }
            
            if httpResponse.statusCode == 200, let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let token = jsonResponse["token"] as? String {
                        print("Token reçu: \(token)")
                        
                        AuthManager.shared.saveToken(token: token)
                        
                        DispatchQueue.main.async {
                            self.onLoginSucceed()
                        }
                    } else {
                        print("Token non trouvé dans la réponse")
                        DispatchQueue.main.async {
                            self.error = ErrorWrapper(message: "Token non trouvé dans la réponse.")
                        }
                    }
                } catch {
                    print("Erreur de parsing JSON: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.error = ErrorWrapper(message: "Erreur de parsing JSON : \(error.localizedDescription)")
                    }
                }
            } else {
                print("Échec de la connexion: Status code \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.error = ErrorWrapper(message: "Échec de la connexion : Code \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    // Validation d'une adresse e-mail avec une expression régulière
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}
