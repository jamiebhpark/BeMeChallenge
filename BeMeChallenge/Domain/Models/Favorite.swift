// Domain/Models/Favorite.swift
import Foundation
import FirebaseFirestore

struct Favorite: Identifiable, Codable {
    @DocumentID var id: String?
    var itemId: String      // 즐겨찾기할 아이템의 ID (챌린지나 게시물의 Document ID)
    var type: String        // "challenge" 또는 "post"
    var createdAt: Date?
}
