// Presentation/ViewModels/DailyChallengeViewModel.swift
import Foundation
import FirebaseFirestore

class DailyChallengeViewModel: ObservableObject {
    @Published var dailyChallenge: DailyChallenge?
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    /// 오늘의 챌린지를 Firestore에서 조회합니다.
    /// 본 예제에서는 "dailyChallenges" 컬렉션의 문서 ID로 "today"를 사용합니다.
    func fetchTodayChallenge() {
        db.collection("dailyChallenges").document("today").getDocument { [weak self] snapshot, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            if let dailyChallenge = try? snapshot?.data(as: DailyChallenge.self) {
                DispatchQueue.main.async {
                    self?.dailyChallenge = dailyChallenge
                }
            } else {
                DispatchQueue.main.async {
                    self?.errorMessage = "오늘의 챌린지 정보를 가져올 수 없습니다."
                }
            }
        }
    }
}
