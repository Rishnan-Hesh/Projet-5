import SwiftUI

struct AllTransactionsView: View {
    let transactions: [Transaction]

    var body: some View {
        List(transactions) { transaction in
            HStack {
                Text(transaction.description)
                Spacer()
                Text(transaction.amount)
            }
        }
        .navigationTitle("All Transactions")
    }
}

#Preview {
    NavigationView {
        AllTransactionsView(transactions: [
            Transaction(description: "Mock 1", amount: "-€1.00"),
            Transaction(description: "Mock 2", amount: "+€2.00")
        ])
    }
}
