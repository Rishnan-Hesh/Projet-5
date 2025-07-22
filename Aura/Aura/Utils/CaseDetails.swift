import SwiftUI

struct TransactionCaseView: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            Image(systemName: transaction.amount.contains("+") ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                .foregroundColor(transaction.amount.contains("+") ? .green : .red)
            Text(transaction.description)
            Spacer()
            Text(transaction.amount)
                .fontWeight(.bold)
                .foregroundColor(transaction.amount.contains("+") ? .green : .red)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}
