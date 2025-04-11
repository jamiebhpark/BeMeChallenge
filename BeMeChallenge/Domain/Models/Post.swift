// Domain/Models/Post.swift
import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable {
    var id: String
    var challengeId: String
    var userId: String
    var imageUrl: String
    var createdAt: Date
    var reactions: [String: Int]
    var reported: Bool
}
