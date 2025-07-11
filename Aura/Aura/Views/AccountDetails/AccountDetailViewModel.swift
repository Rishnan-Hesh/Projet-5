import Foundation

class AccountDetailViewModel: ObservableObject {
    @Published var totalAmount: String = "€0.00"
    @Published var recentTransactions: [Transaction] = []
    
    var allTransactions: [Transaction] = []
    
    init() {
        Task {
            await fetchAccountDetails()
        }
    }
    
    func fetchAccountDetails() async {
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
        }
    }
    
    struct AccountResponse: Codable {
        let currentBalance: Decimal
        let transactions: [BackendTransaction]
    }
    
    struct BackendTransaction: Codable {
        let value: Decimal
        let label: String
    }
}
