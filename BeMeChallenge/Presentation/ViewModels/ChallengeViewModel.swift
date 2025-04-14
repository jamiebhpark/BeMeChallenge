// ChallengeViewModel.swift
import Foundation
import FirebaseFirestore
import Combine

// 모델 예제: Domain/Models/Challenge.swift
struct Challenge: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var participantsCount: Int
    var endDate: Date
    // 필요 시 추가 필드: type, createdAt 등
}

class ChallengeViewModel: ObservableObject {
    @Published var challenges: [Challenge] = []
    private var db = Firestore.firestore()
    
    // 실시간 스냅샷 리스너 설정 – 변경 사항 자동 반영
    func fetchChallenges() {
        db.collection("challenges")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching challenges: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                print("Documents count: \(documents.count)")
                self.challenges = documents.compactMap { doc in
                    let data = doc.data()
                    print("Document data: \(data)")
                    guard let title = data["title"] as? String,
                          let description = data["description"] as? String,
                          let participantsCount = data["participantsCount"] as? Int,
                          let endTimestamp = data["endDate"] as? Timestamp else { return nil }
                    let endDate = endTimestamp.dateValue()
                    return Challenge(id: doc.documentID, title: title, description: description, participantsCount: participantsCount, endDate: endDate)
                }
            }
    }

    
    // 챌린지 참여 시 참여자 수 업데이트 예제
    func joinChallenge(challengeId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let challengeRef = db.collection("challenges").document(challengeId)
        challengeRef.updateData(["participantsCount": FieldValue.increment(Int64(1))]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // 추가: 참여 기록을 사용자 도큐먼트에 업데이트하는 로직도 구현 가능
}
