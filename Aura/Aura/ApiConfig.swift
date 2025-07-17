import Foundation

struct ApiConfig {
    static let baseUrl = "http://127.0.0.1:8080"
    
    enum Endpoint: String {
        case auth = "/auth"
        case account = "/account"
<<<<<<< HEAD
        case transfer = "/account/transfer"
=======
>>>>>>> b1b4c8c5651bfbab9337c524738acbb3f1489c13
    }

    static func url(for endpoint: Endpoint) -> URL? {
        return URL(string: baseUrl + endpoint.rawValue)
    }
}
