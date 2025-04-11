// ReactionService.swift
import Foundation
import FirebaseFirestore

class ReactionService {
    static let shared = ReactionService()
    private let db = Firestore.firestore()
    
    /// 지정된 게시물(postId)에 대해 주어진 이모티콘(reactionType)을 업데이트합니다.
    /// (여기서는 단순히 반응 카운트를 증가시키는 예제입니다.)
    func updateReaction(forPost postId: String, reactionType: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let postRef = db.collection("challengePosts").document(postId)
        postRef.updateData([
            "reactions.\(reactionType)": FieldValue.increment(Int64(1))
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                // 이벤트 로깅 추가: 여기서 challengeId 대신 postId를 사용하지만, 실제 서비스에서는 챌린지 ID 정보가 별도로 필요할 수 있습니다.
                AnalyticsManager.shared.logReactionClick(challengeId: postId, reactionType: reactionType)
                completion(.success(()))
            }
        }
    }
}
