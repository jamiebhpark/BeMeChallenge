// BadgeService.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth

class BadgeService {
    static let shared = BadgeService()
    private let db = Firestore.firestore()
    
    /// 현재 사용자의 뱃지를 Firestore에서 조회합니다.
    func fetchUserBadges(completion: @escaping (Result<[Badge], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "BadgeService", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."])))
            return
        }
        db.collection("users").document(userId).collection("badges")
            .order(by: "earnedDate", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let badges: [Badge] = snapshot?.documents.compactMap {
                    try? $0.data(as: Badge.self)
                } ?? []
                completion(.success(badges))
            }
    }
    
    /// 사용자가 뱃지를 획득하도록 수여합니다.
    func awardBadge(_ badge: Badge, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "BadgeService", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."])))
            return
        }
        var badgeToAward = badge
        badgeToAward.earned = true
        badgeToAward.earnedDate = Date()
        
        let badgeDocID = badge.id ?? UUID().uuidString
        db.collection("users").document(userId).collection("badges").document(badgeDocID)
            .setData(from: badgeToAward) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}
