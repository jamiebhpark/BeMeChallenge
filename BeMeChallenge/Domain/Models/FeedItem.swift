// Domain/Models/FeedItem.swift
import Foundation
import FirebaseFirestoreSwift

struct FeedItem: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String       // 활동을 발생시킨 사용자 ID
    var username: String     // 사용자 닉네임 (optional, 실시간 업데이트를 위해 저장)
    var activityType: String // 예: "challenge_participation", "post_upload", "review_submitted", 등
    var message: String      // 피드에 표시할 상세 메시지
    var createdAt: Date?
}
