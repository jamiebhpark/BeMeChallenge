// RecommendationViewModel.swift
import Foundation
import FirebaseFirestore
import Combine

class RecommendationViewModel: ObservableObject {
    @Published var recommendedChallenges: [Challenge] = []
    private let db = Firestore.firestore()
    
    /// Firestore의 "challenges" 컬렉션에서 활성화된 챌린지를 참여자 수 기준 내림차순으로 조회합니다.
    /// 최대 10개의 챌린지를 추천합니다.
    func fetchRecommendedChallenges() {
        db.collection("challenges")
            .whereField("isActive", isEqualTo: true)
            .order(by: "participantsCount", descending: true)
            .limit(to: 10)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("추천 챌린지 조회 에러: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let challenges: [Challenge] = documents.compactMap { doc in
                    let data = doc.data()
                    guard let title = data["title"] as? String,
                          let description = data["description"] as? String,
                          let participantsCount = data["participantsCount"] as? Int,
                          let endTimestamp = data["endDate"] as? Timestamp
                    else { return nil }
                    let endDate = endTimestamp.dateValue()
                    return Challenge(id: doc.documentID, title: title, description: description, participantsCount: participantsCount, endDate: endDate)
                }
                DispatchQueue.main.async {
                    self.recommendedChallenges = challenges
                }
            }
    }
}
