//
//  AuraApp.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

@main
struct AuraApp: App {
    @StateObject var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if viewModel.isLogged {
                    TabView {
                        AccountDetailView(viewModel: viewModel.accountDetailViewModel)
                            .tabItem {
                                Label("Account", systemImage: "person.crop.circle")
                            }

                        MoneyTransferView(viewModel: viewModel.moneyTransferViewModel)
                            .tabItem {
                                Label("Transfer", systemImage: "arrow.right.arrow.left.circle")
                            }
                    }
                } else {
                    AuthentificationView(viewModel: viewModel.authentificationViewModel)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                                removal: .move(edge: .top).combined(with: .opacity)))
                    
                }
            }
            .accentColor(Color(hex: "#94A684"))
            .animation(.easeInOut(duration: 0.5), value: UUID())
        }
    }
}
