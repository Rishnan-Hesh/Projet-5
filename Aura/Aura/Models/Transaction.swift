import Foundation

struct Transaction: Codable, Identifiable {
    var id = UUID()
    let description: String
    let amount: String
}
