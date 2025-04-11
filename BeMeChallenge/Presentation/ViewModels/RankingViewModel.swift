// RankingViewModel.swift
import Foundation
import FirebaseFirestore

struct RankingUser: Identifiable {
    var id: String
    var nickname: String
    var participationCount: Int
}

class RankingViewModel: ObservableObject {
    @Published var rankingUsers: [RankingUser] = []
    private let db = Firestore.firestore()
    
    /// 모든 사용자의 참여 횟수를 기준으로 랭킹을 조회합니다.
    func fetchRanking() {
        db.collection("users")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Ranking 조회 에러: \(error.localizedDescription)")
                    return
                }
                let users = snapshot?.documents.compactMap { doc -> RankingUser? in
                    let data = doc.data()
                    guard let nickname = data["nickname"] as? String,
                          let participationCount = data["participationCount"] as? Int
                    else { return nil }
                    return RankingUser(id: doc.documentID, nickname: nickname, participationCount: participationCount)
                } ?? []
                // 참여 횟수가 높은 순으로 정렬
                let sortedUsers = users.sorted { $0.participationCount > $1.participationCount }
                DispatchQueue.main.async {
                    self.rankingUsers = sortedUsers
                }
            }
    }
}
