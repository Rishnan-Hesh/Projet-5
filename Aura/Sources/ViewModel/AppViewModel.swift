import Foundation

class AppViewModel: ObservableObject {
    @Published var isLogged: Bool = false

    let accountDetailViewModel = AccountDetailViewModel()

    lazy var moneyTransferViewModel = MoneyTransferViewModel(
        accountViewModel: accountDetailViewModel
    )

    lazy var authentificationViewModel = AuthentificationViewModel(
        onLoginSucceed: {
            self.isLogged = true
        }
    )
}



