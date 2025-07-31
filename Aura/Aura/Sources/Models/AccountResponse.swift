import Foundation

struct AccountResponse: Codable {
    let currentBalance: Decimal
    let transactions: [BackendTransaction]
}
