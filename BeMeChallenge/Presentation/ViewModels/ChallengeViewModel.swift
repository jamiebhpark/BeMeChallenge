// ChallengeViewModel.swift
import Foundation
import FirebaseFirestore
import Combine

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
    // 사용자가 참여한 챌린지 ID를 저장할 집합
    @Published var participatedChallenges: Set<String> = []
    
    private var db = Firestore.firestore()
    
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
                    guard let title = data["title"] as? String,
                          let description = data["description"] as? String,
                          let participantsCount = data["participantsCount"] as? Int,
                          let endTimestamp = data["endDate"] as? Timestamp else { return nil }
                    let endDate = endTimestamp.dateValue()
                    return Challenge(id: doc.documentID, title: title, description: description, participantsCount: participantsCount, endDate: endDate)
                }
            }
    }
    
    func joinChallenge(challengeId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // 이미 참여한 경우 실패 처리
        if participatedChallenges.contains(challengeId) {
            completion(.failure(NSError(domain: "ChallengeViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "이미 참여하셨습니다."])))
            return
        }
        
        let challengeRef = db.collection("challenges").document(challengeId)
        challengeRef.updateData(["participantsCount": FieldValue.increment(Int64(1))]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                // 참여 성공 시, 참여 집합에 해당 챌린지 ID 추가
                self.participatedChallenges.insert(challengeId)
                completion(.success(()))
            }
        }
    }
}
