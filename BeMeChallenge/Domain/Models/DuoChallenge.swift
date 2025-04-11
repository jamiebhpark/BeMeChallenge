// Domain/Models/DuoChallenge.swift
import Foundation
import FirebaseFirestore

struct DuoChallenge: Identifiable, Codable {
    @DocumentID var id: String?
    var challengeId: String
    var creatorId: String
    var partnerId: String?   // 친구가 참여하면 채워짐; 아직 참여하지 않은 경우 nil 또는 빈 문자열
    var status: String       // "pending", "active", "completed" 등
    var createdAt: Date?
}
