import SwiftUI

struct AccountDetailView: View {
    @ObservedObject var viewModel: AccountDetailViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(spacing: 10) {
                        Text("Your Balance")
                            .font(.headline)
                        
                        Text(viewModel.totalAmount)
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(Color(hex: "#94A684"))
                        
                        Image(systemName: "eurosign.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                            .foregroundColor(Color(hex: "#94A684"))
                    }
                    .padding(.top)

                    // Recent Transactions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Transactions")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(viewModel.recentTransactions) { transaction in
                            HStack {
                                Image(systemName: transaction.amount.contains("+") ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                                    .foregroundColor(transaction.amount.contains("+") ? .green : .red)

                                Text(transaction.description)

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

                    // Navigation to all transactions
                    NavigationLink(destination: AllTransactionsView(transactions: viewModel.allTransactions)) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("See Transaction Details")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#94A684"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            .background(Color(.systemBackground))
        }
    }
}

