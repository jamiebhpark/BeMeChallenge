// FavoritesViewModel.swift
import Foundation
import Combine

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Favorite] = []
    @Published var errorMessage: String? = nil
    
    func loadFavorites() {
        FavoriteService.shared.fetchFavorites { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let favs):
                    self.favorites = favs
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func addFavorite(itemId: String, type: String) {
        FavoriteService.shared.addFavorite(itemId: itemId, type: type) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.loadFavorites()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func removeFavorite(itemId: String, type: String) {
        FavoriteService.shared.removeFavorite(itemId: itemId, type: type) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.loadFavorites()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
