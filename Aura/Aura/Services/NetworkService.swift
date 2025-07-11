import Foundation

struct NetworkService {

    enum NetworkServiceError: Error {
        case invalidURL
        case noData
        case decodingFailed
    }

    func fetchAccountDetails() async throws {
        guard let url = ApiConfig.url(for: .account) else {
            print("URL invalide")
            return
        }

        guard let token = AuthManager.shared.getToken() else {
            print("Token manquant")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "token")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(AccountResponse.self, from: data)

            //question
            let transactions = response.transactions.map { tx in
                let formatted = tx.value >= 0
                    ? "+€\(String(format: "%.2f", NSDecimalNumber(decimal: tx.value).doubleValue))"
                    : "-€\(String(format: "%.2f", NSDecimalNumber(decimal: abs(tx.value)).doubleValue))"
                return Transaction(description: tx.label, amount: formatted)
            }

            DispatchQueue.main.async {
                self.totalAmount = "€\(String(format: "%.2f", NSDecimalNumber(decimal: response.currentBalance).doubleValue))"
                self.allTransactions = transactions
                self.recentTransactions = Array(transactions.prefix(3))
            }
        } catch {
            print("Erreur lors du chargement : \(error.localizedDescription)")

            throw NetworkServiceError.noData
        }
    }

    func authenticate(username: String, password: String) async throws {
        // Setup du backend
        guard let url = ApiConfig.url(for: .auth) else {
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
                        print(jsonResponse)

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
}
