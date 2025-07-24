//
//  NetworkSessionProtocol.swift
//  Aura
//
//  Created by Damien Rivet on 24/07/2025.
//

import Foundation


protocol NetworkSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
