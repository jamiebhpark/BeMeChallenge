// Domain/Models/DailyChallenge.swift
import Foundation
import FirebaseFirestore

struct DailyChallenge: Identifiable, Codable {
    @DocumentID var id: String?
    var challengeId: String
    var title: String
    var description: String
    var imageUrl: String?
    var startDate: Date
    var endDate: Date
}
