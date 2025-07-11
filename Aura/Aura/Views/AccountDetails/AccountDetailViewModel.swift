import Foundation

class AccountDetailViewModel: ObservableObject {

    private let networkService: NetworkService

    @Published var totalAmount: String = "€0.00"
    @Published var recentTransactions: [Transaction] = []
        
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService

        Task {
            await fetchAccountDetails()
        }
    }

    @MainActor
    func fetchAccountDetails() async {
        do {
            try await networkService.fetchAccountDetails()
        } catch {

        }
    }
}
