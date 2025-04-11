// Domain/Models/SupportChatMessage.swift
import Foundation
import FirebaseFirestore

struct SupportChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    var message: String
    var createdAt: Date
}
