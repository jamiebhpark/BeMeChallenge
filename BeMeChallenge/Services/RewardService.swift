// RewardService.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth

class RewardService {
    static let shared = RewardService()
    private let db = Firestore.firestore()
    
    /// 사용자의 포인트를 지정한 값 만큼 증가시킵니다.
    func addPoints(_ points: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "RewardService", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."])))
            return
        }
        let userRef = db.collection("users").document(userId)
        userRef.updateData([
            "points": FieldValue.increment(Int64(points))
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// 사용자의 현재 포인트를 조회합니다.
    func fetchUserPoints(completion: @escaping (Result<Int, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "RewardService", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."])))
            return
        }
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            let data = document?.data()
            let points = data?["points"] as? Int ?? 0
            completion(.success(points))
        }
    }
}
