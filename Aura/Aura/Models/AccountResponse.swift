//
//  AccountResponse 2.swift
//  Aura
//
//  Created by Damien Rivet on 24/07/2025.
//

import Foundation

struct AccountResponse: Codable {
    let currentBalance: Decimal
    let transactions: [BackendTransaction]
}
