// BadgeViewModel.swift
import Foundation
import Combine

class BadgeViewModel: ObservableObject {
    @Published var badges: [Badge] = []
    @Published var errorMessage: String?
    
    func loadUserBadges() {
        BadgeService.shared.fetchUserBadges { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedBadges):
                    self?.badges = fetchedBadges
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
