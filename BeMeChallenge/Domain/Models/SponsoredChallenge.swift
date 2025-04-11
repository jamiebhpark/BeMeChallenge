// Domain/Models/SponsoredChallenge.swift
import Foundation
import FirebaseFirestore

struct SponsoredChallenge: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var sponsorName: String
    var imageUrl: String
    var sponsoredLink: String?  // 선택적: 클릭 시 외부로 이동할 링크
    var createdAt: Date?
}
