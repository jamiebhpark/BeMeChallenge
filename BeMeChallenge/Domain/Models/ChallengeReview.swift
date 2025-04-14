// Domain/Models/ChallengeReview.swift
import Foundation
import FirebaseFirestore

struct ChallengeReview: Identifiable, Codable {
    @DocumentID var id: String?
    var challengeId: String
    var userId: String
    var rating: Int // 1에서 5까지
    var reviewText: String
    var createdAt: Date?
}
