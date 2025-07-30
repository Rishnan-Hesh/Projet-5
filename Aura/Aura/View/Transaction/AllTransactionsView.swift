import SwiftUI

struct AllTransactionsView: View {
    let transactions: [Transaction]
    
    var body: some View {
        List(transactions) { transaction in
            TransactionCaseView(transaction: transaction)
        }
        .scrollContentBackground(.hidden)// <-- Cache le fond du scroll pour List
        .navigationTitle("All Transactions")
        
        
        //.listRowBackground(Color.white)            // <-- Force le fond de chaque ligne à blanc
        //.background(Color.white.ignoresSafeArea())  // <-- Fond général de la view Essaie avec mes rien ne change.
    }
    
}

#Preview {
    TransactionCaseView(transaction: Transaction(description: "Achat café", amount: "-€2,20"));
    TransactionCaseView(transaction: Transaction(description: "Achat citron", amount: "-€5"));
    TransactionCaseView(transaction: Transaction(description: "Achat menthe", amount: "-€2.30"));
    TransactionCaseView(transaction: Transaction(description: "vente vinted", amount: "+€45"));
    TransactionCaseView(transaction: Transaction(description: "Achat café", amount: "-€2.30"));
    TransactionCaseView(transaction: Transaction(description: "Achat café", amount: "-€2.30"))
}
