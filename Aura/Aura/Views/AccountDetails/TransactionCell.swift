//
//  TransactionCell.swift
//  Aura
//
//  Created by Damien Rivet on 11/07/2025.
//

import SwiftUI

struct TransactionCell: View {

    // MARK: - Constants

    private let transaction: Transaction

    // MARK: - Initializers

    init(_ transaction: Transaction) {
        self.transaction = transaction
    }

    // MARK: - View

    var body: some View {
        HStack {
            Image(systemName: transaction.amount.contains("+") ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                .foregroundColor(transaction.amount.contains("+") ? .green : .red)

            Text(transaction.description)

            Text(transaction.amount)
                .fontWeight(.bold)
                .foregroundColor(transaction.amount.contains("+") ? .green : .red)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}
