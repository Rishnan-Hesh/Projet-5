import Foundation

class MoneyTransferViewModel: ObservableObject {
    @Published var recipient: String = ""
    @Published var amount: String = ""
    @Published var transferMessage: String? = nil
    
    
    // 🔐 Token reçu après connexion
    var token: String = ""
    var accountViewModel: AccountDetailViewModel?
    
    init(accountViewModel: AccountDetailViewModel? = nil) {
        self.accountViewModel = accountViewModel
    }
    
    
    
    func sendMoney(completion: @escaping () -> Void) {
        // Valider le destinataire
        guard isValidRecipient(recipient) else {
            transferMessage = "Destinataire invalide (email ou numéro FR requis)."
            completion()
            return
        }
        
        // Valider le montant
        guard let amountValue = Double(amount), amountValue > 0 else {
            transferMessage = "Montant invalide. Entrez un nombre positif."
            completion()
            return
        }
        
        transferMessage = "Virement envoyé !"
        self.recipient = ""
        self.amount = ""
        completion()
    }
    
    
    // Validation du destinataire
    internal func isValidRecipient(_ input: String) -> Bool {
        let emailRegEx = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let phoneRegEx = "^\\+33 ?[1-9](\\d{2}){4}$|^0[1-9](\\d{2}){4}$"
        let matchesEmail = NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: input)
        let matchesPhone = NSPredicate(format: "SELF MATCHES %@", phoneRegEx).evaluate(with: input)
        return matchesEmail || matchesPhone
    }
}
