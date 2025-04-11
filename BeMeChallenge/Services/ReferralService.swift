// ReferralService.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth

class ReferralService {
    static let shared = ReferralService()
    private let db = Firestore.firestore()
    
    /// 추천 기록 추가: 친구가 추천 코드를 사용하여 가입한 경우, 해당 추천 기록을 Firestore에 추가합니다.
    func addReferral(referredId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "ReferralService", code: -1, userInfo: [NSLocalizedDescriptionKey: "현재 사용자를 찾을 수 없습니다."])))
            return
        }
        let newReferral: [String: Any] = [
            "referrerId": currentUserId,
            "referredId": referredId,
            "createdAt": FieldValue.serverTimestamp(),
            "rewardPoints": 10
        ]
        db.collection("referrals").addDocument(data: newReferral) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// 현재 사용자의 추천 내역(자신이 referrer인 추천 건수)을 조회합니다.
    func fetchReferrals(for userId: String, completion: @escaping (Result<Int, Error>) -> Void) {
        db.collection("referrals")
            .whereField("referrerId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let count = snapshot?.documents.count ?? 0
                completion(.success(count))
            }
    }
}
