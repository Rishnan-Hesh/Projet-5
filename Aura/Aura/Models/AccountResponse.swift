//
//  AccountResponse 2.swift
//  Aura
//
//  Created by Damien Rivet on 11/07/2025.
//

struct AccountResponse: Codable {
    let currentBalance: Double
    let transactions: [BackendTransaction]
}
