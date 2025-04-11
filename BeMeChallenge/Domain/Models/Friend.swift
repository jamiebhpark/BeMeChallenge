// Domain/Models/Friend.swift
import Foundation
import FirebaseFirestore

struct Friend: Identifiable, Codable {
    @DocumentID var id: String?
    var nickname: String
    var userId: String
    var profilePictureURL: String?
}
