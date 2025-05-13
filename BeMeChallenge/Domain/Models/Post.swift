// ChallengePost.swift
import Foundation
import FirebaseFirestore

/// Firestore → 챌린지 포스트 도메인 모델
struct Post: Identifiable, Codable, Hashable {      // ⬅️ Hashable 추가
    @DocumentID var id: String?                     // Firestore 문서 ID
    let challengeId: String
    let userId: String
    let imageUrl: String
    let createdAt: Date
    let reactions: [String: Int]
    let reported: Bool
    let caption: String?

    // CodingKeys – 필요 시 명시
    enum CodingKeys: String, CodingKey {
        case id, challengeId, userId, imageUrl,
             createdAt, reactions, reported, caption
    }
}
