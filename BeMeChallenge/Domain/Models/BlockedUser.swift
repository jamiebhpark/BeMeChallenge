// Domain/Models/BlockedUser.swift
import Foundation
import FirebaseFirestore

struct BlockedUser: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var nickname: String
    var profilePictureURL: String?
}
