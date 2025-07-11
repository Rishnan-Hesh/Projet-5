//
//  AccountResponse.swift
//  Aura
//
//  Created by Johan Trino on 11/07/2025.
//

import Foundation

struct AccountResponse: Codable {
    let totalAmount: String
    let transactions: [Transaction]
}
