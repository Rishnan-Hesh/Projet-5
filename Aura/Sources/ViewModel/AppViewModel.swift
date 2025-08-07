import Foundation

class AppViewModel: ObservableObject {
    @Published
    var isLogged = false

    lazy var authentificationViewModel = AuthentificationViewModel(
        onLoginSucceed: {
            self.isLogged = true
        }
    )
}


