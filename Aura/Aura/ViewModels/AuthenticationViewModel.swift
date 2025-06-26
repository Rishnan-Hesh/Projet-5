//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AuthenticationViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    
    let onLoginSucceed: (() -> ())
    
    init(_ callback: @escaping () -> ()) {
        self.onLoginSucceed = callback
    }
    
    func login() {
        // Setup du backend
        guard let url = URL(string:"http://127.0.0.1:8080/auth") else {
            print("URL invalide")
            return
        }
        
        let body: [String: String] = [
            "username": username,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Erreur de conversion JSON")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // a faire a chaque fois
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        //Requete
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Gestion des erreurs
            if let error = error {
                print("Erreur réseau: \(error.localizedDescription)")
                // utilisable partout grace a swift
                return
            }
            
            // Vérifier la réponse HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Réponse invalide")
                return
            }
            // explication ?
            if httpResponse.statusCode == 200, let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let token = jsonResponse["token"] as? String {
                        print("Token reçu: \(token)")
                        
                        // On stocke le token
                        AuthManager.shared.saveToken(token: token)
                        
                        DispatchQueue.main.async {
                            self.onLoginSucceed()
                        }
                    } else {
                        print("Token non trouvé dans la réponse")
                    }
                } catch {
                    print("Erreur de parsing JSON: \(error.localizedDescription)")
                }
            } else {
                print("Échec de la connexion: Status code \(httpResponse.statusCode)")
            }
        }.resume()
    }
}
