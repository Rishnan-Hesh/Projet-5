import Foundation

class AuthentificationViewModel: ObservableObject {
    @Published var username: String = "test@aura.app"
    @Published var password: String = "test123"
    @Published var error: ErrorWr? = nil
    @Published var isAuthenticated = false
    
    // injected closure for tests
    var performLoginRequest: ((_ username: String, _ password: String, _ completion: @escaping (Result<String, Error>) -> Void) -> Void)
    var onLoginSucceed: () -> Void
    
    init(
        onLoginSucceed: @escaping () -> Void,
        performLoginRequest: @escaping (_ username: String, _ password: String, _ completion: @escaping (Result<String, Error>) -> Void) -> Void = AuthentificationViewModel.defaultLoginRequest
    ) {
        self.onLoginSucceed = onLoginSucceed
        self.performLoginRequest = performLoginRequest
    }
    
    
    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    func login() {
        // reset before login to force Combine to notify if new fail
        DispatchQueue.main.async { [weak self] in
            self?.error = nil
        }
        performLoginRequest(username, password) { [weak self] result in
            DispatchQueue.main.async {
                if let token = try? result.get() {


                    AuthManager.shared.saveToken(token: token)

                    self?.isAuthenticated = true
                    self?.onLoginSucceed()
                } else {
                    let error = (try? result.get()) == nil ? {
                        if case let .failure(err) = result { return err }
                        else { return NSError(domain: "", code: 0, userInfo: nil) }
                    }() : nil
                    if let error = error {
                        self?.error = ErrorWr(message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    //func network
    static func defaultLoginRequest(
        username: String,
        password: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let url = ApiConfig.url(for: .auth) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [
                NSLocalizedDescriptionKey : "URL invalide"
            ])))
            return
        }
        
        let body = ["username": username, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [
                NSLocalizedDescriptionKey : "Erreur JSON"
            ])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [
                    NSLocalizedDescriptionKey : "Réponse invalide du serveur."
                ])))
                return
            }
            
            if httpResponse.statusCode == 200, let data = data {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = jsonResponse["token"] as? String {
                    completion(.success(token))
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [
                        NSLocalizedDescriptionKey : "Token non trouvé dans la réponse."
                    ])))
                }
            } else {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                    NSLocalizedDescriptionKey : "Échec de la connexion : Code \(httpResponse.statusCode)"
                ])))
            }
        }.resume()
    }
}
