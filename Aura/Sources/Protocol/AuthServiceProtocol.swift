import Foundation

protocol AuthServiceProtocol {
    
    func login(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void)
}
