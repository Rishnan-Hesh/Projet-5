import Foundation

class MoneyTransferViewModel: ObservableObject {
    @Published var recipient: String = ""
    @Published var amount: String = ""
    @Published var transferMessage: String = ""
    
    // 🔐 Token reçu après connexion
    var token: String = ""
    var accountViewModel: AccountDetailViewModel?
    
    init(accountViewModel: AccountDetailViewModel? = nil) {
        self.accountViewModel = accountViewModel
    }
    
    // MARK: - Authentification via /auth
    func login(completion: @escaping (Bool) -> Void) {
        guard let url = ApiConfig.url(for: .auth) else {
            transferMessage = "URL de login invalide."
            completion(false)
            return
        }
        
        let authentificators: [String: Any] = [
            "username": "test@aura.app",
            "password": "test123"
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: authentificators) else {
            transferMessage = "Erreur de création du JSON de login."
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.transferMessage = "Erreur lors du login : \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let receivedToken = json["token"] as? String else {
                    self.transferMessage = "Réponse invalide de l'API /auth"
                    completion(false)
                    return
                }
                
                self.token = receivedToken
                self.transferMessage = "✅ Connexion réussie. Token reçu."
                completion(true)
            }
        }
        
        task.resume()
    }
    
    func sendMoney(completion: (() -> Void)? = nil) {
        //Valider le destinataire
        guard isValidRecipient(recipient) else {
            transferMessage = "Destinataire invalide (email ou numéro FR requis)."
            return
        }
        
        //Valider le montant
        guard let amountValue = Double(amount), amountValue > 0 else {
            transferMessage = "Montant invalide. Entrez un nombre positif."
            return
        }
        
        //URL
        guard let url = ApiConfig.url(for: .transfer) else {
            transferMessage = "URL de l'API invalide."
            return
        }
        
        //body JSON
        let body: [String: Any] = [
            "recipient": recipient,
            "amount": amountValue
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            transferMessage = "Erreur de conversion JSON."
            return
        }
        
        //requête
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "token") //Header d’authentification
        request.httpBody = jsonData
        
        //Lancer la requête
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                defer { completion?() }
                if let error = error {
                    self.transferMessage = "Erreur: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.transferMessage = "Réponse invalide du serveur."
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    self.transferMessage = "Transfert de \(amountValue)€ vers \(self.recipient) effectué !"
                    
                    // Ajout immédiat dans la vue
                    self.accountViewModel?.ajouterTransactionLocale(recipient: self.recipient, montant: amountValue)
                    
                    // MAJ instantanée côté UI
                    self.accountViewModel?.soustraireDuSolde(amountValue)
                    
                } else {
                    self.transferMessage = "Échec du transfert (code \(httpResponse.statusCode))."
                }
            }
        }
        
        task.resume()
    }
    //Validation du destinataire
    private func isValidRecipient(_ input: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let phoneRegEx = "^\\+33 ?[1-9]( ?\\d{2}){4}$|^0[1-9](\\d{2}){4}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: input)
        || NSPredicate(format: "SELF MATCHES %@", phoneRegEx).evaluate(with: input)
    }
}

