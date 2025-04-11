// Domain/Models/Referral.swift
import Foundation
import FirebaseFirestore

struct Referral: Identifiable, Codable {
    @DocumentID var id: String?
    var referrerId: String      // 추천한 사용자 ID (추천 코드는 이 값과 동일)
    var referredId: String?     // 추천 받은 친구의 ID (가입 후 업데이트)
    var createdAt: Date?
    var rewardPoints: Int       // 추천 당 획득 포인트 (예: 10)
}
