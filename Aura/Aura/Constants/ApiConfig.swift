import Foundation

enum ApiConfig {

    static let baseUrl = "http://127.0.0.1:8080"
    
    enum Endpoint: String {
        case auth = "/auth"
        case account = "/account"
    }

    static func url(for endpoint: Endpoint) -> URL? {
        URL(string: baseUrl + endpoint.rawValue)
    }
}
