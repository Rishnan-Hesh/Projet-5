import Foundation


// Structure d'erreur réutilisable, à mettre dans un fichier à part ?
struct ErrorWr: Identifiable {
    let id = UUID()
    let message: String
}
