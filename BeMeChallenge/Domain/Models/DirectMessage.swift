// Domain/Models/DirectMessage.swift
import Foundation
import FirebaseFirestore

struct DirectMessage: Identifiable, Codable {
    @DocumentID var id: String?
    var conversationId: String  // "min(currentUserId, friendId)_max(currentUserId, friendId)" 형식으로 생성
    var senderId: String
    var receiverId: String
    var message: String
    var createdAt: Date?
}
