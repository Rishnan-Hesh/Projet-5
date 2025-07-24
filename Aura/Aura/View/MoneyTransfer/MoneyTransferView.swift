import SwiftUI

struct MoneyTransferView: View {
    @ObservedObject var viewModel: MoneyTransferViewModel
    @State private var isProcessing = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 28) {
                Text("Transfert d'argent")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#94A684"))
                    .padding(.top, 36)

                VStack(spacing: 16) {
                    TextField("Email ou téléphone du destinataire", text: $viewModel.recipient)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .keyboardType(.emailAddress)

                    TextField("Montant (€)", text: $viewModel.amount)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .keyboardType(.decimalPad)
                }
                .padding(.horizontal, 16)

                Button(action: {
                    isProcessing = true
                    viewModel.sendMoney {
                        isProcessing = false
                    }
                }) {
                    Text("Envoyer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#94A684"))
                        .cornerRadius(12)
                }
                .disabled(isProcessing)
                .padding(.horizontal, 16)

                // Message de feedback
                if !viewModel.transferMessage.isEmpty {
                    Text(viewModel.transferMessage)
                        .foregroundColor(viewModel.transferMessage.contains("effectué") ? .green : .red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .transition(.opacity)
                }

                Spacer()
            }
            .padding(.bottom, 18)
        }
    }
}

#Preview {
    let vm: MoneyTransferViewModel = {
        let accountVM = AccountDetailViewModel()
        let vm = MoneyTransferViewModel(accountViewModel: accountVM)
        vm.recipient = "demo@aura.app"
        vm.amount = "20"
        vm.transferMessage = ""
        return vm
    }()

    return MoneyTransferView(viewModel: vm)
}
