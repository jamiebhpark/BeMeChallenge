// ReferralProgramViewModel.swift
import Foundation
import FirebaseAuth
import Combine

class ReferralProgramViewModel: ObservableObject {
    @Published var referralCount: Int = 0
    @Published var rewardPoints: Int = 0
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    /// 사용자 추천 코드는 현재 사용자의 UID를 사용합니다.
    var referralCode: String? {
        Auth.auth().currentUser?.uid
    }
    
    /// 현재 사용자의 추천 건수를 조회하여, 보상 포인트를 계산합니다.
    func fetchReferralStats() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "현재 사용자 정보를 찾을 수 없습니다."
            return
        }
        ReferralService.shared.fetchReferrals(for: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let count):
                    self?.referralCount = count
                    self?.rewardPoints = count * 10
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
