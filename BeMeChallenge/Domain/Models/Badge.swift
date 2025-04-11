// Domain/Models/Badge.swift
import Foundation
import FirebaseFirestore

struct Badge: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var imageUrl: String
    var earned: Bool
    var earnedDate: Date?
}
