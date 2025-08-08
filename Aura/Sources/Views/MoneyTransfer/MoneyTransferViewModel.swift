import Foundation

class MoneyTransferViewModel: ObservableObject {
    @Published var recipient: String = ""
    @Published var amount: String = ""
    @Published var transferMessage: String? = nil
    
    
    // Token received after login
    var token: String = ""
    var accountViewModel: AccountDetailViewModel?
    
    init(accountViewModel: AccountDetailViewModel? = nil) {
        self.accountViewModel = accountViewModel
    }
    
    // Valid recipient
    internal func isValidRecipient(_ input: String) -> Bool {
        let emailRegEx = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let phoneRegEx = "^\\+33 ?[1-9](\\d{2}){4}$|^0[1-9](\\d{2}){4}$"
        let matchesEmail = NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: input)
        let matchesPhone = NSPredicate(format: "SELF MATCHES %@", phoneRegEx).evaluate(with: input)
        return matchesEmail || matchesPhone
    }
    
    func sendMoney(completion: @escaping () -> Void) {
        guard isValidRecipient(recipient) else {
            transferMessage = "Destinataire invalide (email ou numéro FR requis)."
            completion()
            return
        }

        guard let amountValue = Double(amount), amountValue > 0 else {
            transferMessage = "Montant invalide. Entrez un nombre positif."
            completion()
            return
        }

        // ✅ Simuler un envoi : succès
        transferMessage = "Virement effectué avec succès !"

        // ✅ Mise à jour du AccountDetailViewModel
        accountViewModel?.addLocalTransaction(recipient: recipient, montant: amountValue)
        accountViewModel?.amountMinus(amountValue)

        // ✅ Réinitialisation des champs
        self.recipient = ""
        self.amount = ""

        completion()
    }

}
