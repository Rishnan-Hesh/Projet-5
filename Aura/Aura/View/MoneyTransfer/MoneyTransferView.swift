import SwiftUI

struct MoneyTransferView: View {
    @ObservedObject var viewModel: MoneyTransferViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Transfert d'argent")
                .font(.title)
                .bold()

            TextField("Email ou téléphone du destinataire", text: $viewModel.recipient)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)

            TextField("Montant (€)", text: $viewModel.amount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)

            Button("Envoyer") {
                viewModel.sendMoney()
            }
            .buttonStyle(.borderedProminent)

            if !viewModel.transferMessage.isEmpty {
                Text(viewModel.transferMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.login { success in
                if !success {
                    print("❌ Échec de la connexion.")
                } else {
                    print("✅ Login réussi. Token: \(viewModel.token)")
                }
            }
        }
    }
}
