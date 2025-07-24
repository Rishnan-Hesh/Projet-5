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
    
    func sendMoney(completion: (() -> Void)? = nil) {
        // Valider le destinataire
        guard isValidRecipient(recipient) else {
            transferMessage = "Destinataire invalide (email ou numéro FR requis)."
            completion?()
            return
        }

        // Valider le montant
        guard let amountValue = Double(amount), amountValue > 0 else {
            transferMessage = "Montant invalide. Entrez un nombre positif."
            completion?()
            return
        }

        // URL
        guard let url = ApiConfig.url(for: .transfer) else {
            transferMessage = "URL de l'API invalide."
            completion?()
            return
        }

        // body JSON
        let body: [String: Any] = [
            "recipient": recipient,
            "amount": amountValue
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            transferMessage = "Erreur de conversion JSON."
            completion?()   
            return
        }

        // requête
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "token")
        request.httpBody = jsonData

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
                    self.accountViewModel?.ajouterTransactionLocale(recipient: self.recipient, montant: amountValue)
                    self.accountViewModel?.soustraireDuSolde(amountValue)
                } else {
                    self.transferMessage = "Échec du transfert (code \(httpResponse.statusCode))."
                }
            }
        }

        task.resume()
    }

    //Validation du destinataire, fileprivate ne fonctionnait pas ??
    internal func isValidRecipient(_ input: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let phoneRegEx = "^\\+33 ?[1-9]( ?\\d{2}){4}$|^0[1-9](\\d{2}){4}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: input)
        || NSPredicate(format: "SELF MATCHES %@", phoneRegEx).evaluate(with: input)
    }
}

