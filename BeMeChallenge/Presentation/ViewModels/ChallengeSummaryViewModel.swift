// ChallengeSummaryViewModel.swift
import Foundation
import FirebaseFirestore
import Combine

struct ChallengeSummary {
    let totalPosts: Int
    let totalReactions: [String: Int]
    let averageReactions: [String: Double]
}

class ChallengeSummaryViewModel: ObservableObject {
    @Published var summary: ChallengeSummary?
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    // 챌린지 ID를 받아 해당 챌린지의 통계 데이터를 계산합니다.
    func fetchSummary(for challengeId: String) {
        db.collection("challengePosts")
            .whereField("challengeId", isEqualTo: challengeId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                guard let documents = snapshot?.documents else { return }
                var totalPosts = documents.count
                var reactionTotals: [String: Int] = [:]
                
                // 각 게시물의 반응 데이터를 합산
                for doc in documents {
                    if let reactions = doc.data()["reactions"] as? [String: Int] {
                        for (emoji, count) in reactions {
                            reactionTotals[emoji, default: 0] += count
                        }
                    }
                }
                
                // 게시물 수가 0이면 평균은 0
                var averageReactions: [String: Double] = [:]
                if totalPosts > 0 {
                    for (emoji, total) in reactionTotals {
                        averageReactions[emoji] = Double(total) / Double(totalPosts)
                    }
                }
                
                let summary = ChallengeSummary(totalPosts: totalPosts, totalReactions: reactionTotals, averageReactions: averageReactions)
                DispatchQueue.main.async {
                    self?.summary = summary
                }
            }
    }
}
