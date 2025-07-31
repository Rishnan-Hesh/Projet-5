import SwiftUI

struct AccountDetailView: View {
    @ObservedObject var viewModel: AccountDetailViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Scrollable content
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
                                TransactionCaseView(transaction: transaction)
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
                .background(Color(.systemBackground))
                
                // Le bouton doit être ICI, dans le VStack
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
                    .padding([.horizontal, .bottom])
                }
            }
            .background(Color(.systemBackground))
        }
    }
}


#Preview {
    // ViewModel factice pour la preview
    let vm = AccountDetailViewModel()
    vm.totalAmount = "€150.00"
    vm.allTransactions = [
        Transaction(description: "Déjeuner 🍔", amount: "-€12.00"),
        Transaction(description: "Salaire 🤑", amount: "+€2000.00"),
        Transaction(description: "Café ☕️", amount: "-€2.50")
    ]
    vm.recentTransactions = Array(vm.allTransactions.prefix(3))
    
    return AccountDetailView(viewModel: vm)
}


