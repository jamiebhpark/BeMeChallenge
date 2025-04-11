// RewardsViewModel.swift
import Foundation
import Combine

class RewardsViewModel: ObservableObject {
    @Published var points: Int = 0
    
    func loadPoints() {
        RewardService.shared.fetchUserPoints { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let pts):
                    self.points = pts
                case .failure(let error):
                    print("포인트 로드 에러: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func addReward(points: Int) {
        RewardService.shared.addPoints(points) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.loadPoints()
                case .failure(let error):
                    print("포인트 추가 에러: \(error.localizedDescription)")
                }
            }
        }
    }
}
