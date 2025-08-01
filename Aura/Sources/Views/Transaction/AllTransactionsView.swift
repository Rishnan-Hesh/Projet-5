import SwiftUI

struct AllTransactionsView: View {
    let transactions: [Transaction]
    
    var body: some View {
        List(transactions) { transaction in
            TransactionCaseView(transaction: transaction)
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("All Transactions")
        
        
        //.listRowBackground(Color.white)
        //.background(Color.white.ignoresSafeArea())
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
