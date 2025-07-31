import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    private let tokenKey = "authToken"
    
    private init() {}
    
    func saveToken(token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }
    
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}

//pattern singleton
