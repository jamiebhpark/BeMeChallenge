//ChallengePost.swift
import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable {
    @DocumentID var id: String?              // ← 반드시 optional
    let challengeId: String
    let userId: String
    let imageUrl: String
    let createdAt: Date
    let reactions: [String: Int]
    let reported: Bool
    let caption: String?    // ← Optional caption 추가

    // Codable 지원을 위해 필요시 CodingKeys 선언
    enum CodingKeys: String, CodingKey {
        case id
        case challengeId
        case userId
        case imageUrl
        case createdAt
        case reactions
        case reported
        case caption
    }
}
