//
//  NetworkService.swift
//  Aura
//
//  Created by Damien Rivet on 24/07/2025.
//

import Foundation

enum NetworkServiceError: Error {
    case invalidURL
    case invalidResponse
    case invalidPayload
    case networkError
}

protocol NetworkService {

    func call<T: Decodable>(url: String, httpMethod: String, body: Data?) async throws -> T
}

struct NetworkServiceImplementation: NetworkService {

    func call<T: Decodable>(url: String, httpMethod: String, body: Data?) async throws -> T {
        guard let finalURL = URL(string: url) else {
            throw NetworkServiceError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkServiceError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                do {
                    let element = try JSONDecoder().decode(T.self, from: data)

                    return element
                } catch {
                    throw NetworkServiceError.invalidPayload
                }
            } else {
                // TODO: handle other network codes
                throw NetworkServiceError.invalidPayload
            }
        } catch {
            throw NetworkServiceError.networkError
        }
    }
}
