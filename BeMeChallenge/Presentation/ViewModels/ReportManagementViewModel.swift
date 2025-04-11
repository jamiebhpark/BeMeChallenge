// ReportManagementViewModel.swift
import Foundation
import FirebaseFirestore
import Combine

struct ReportedPost: Identifiable, Codable {
    @DocumentID var id: String?
    var challengeId: String
    var userId: String
    var imageUrl: String?
    var reported: Bool
    var createdAt: Date?
}

class ReportManagementViewModel: ObservableObject {
    @Published var reportedPosts: [ReportedPost] = []
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    /// 신고된 게시물 목록을 조회합니다.
    func fetchReportedPosts() {
        db.collection("challengePosts")
            .whereField("reported", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = "신고된 게시물 조회 오류: \(error.localizedDescription)"
                    }
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let posts: [ReportedPost] = documents.compactMap { doc in
                    try? doc.data(as: ReportedPost.self)
                }
                DispatchQueue.main.async {
                    self?.reportedPosts = posts
                }
            }
    }
    
    /// 신고 처리 완료: 해당 게시물의 reported 값을 false로 업데이트합니다.
    func markAsReviewed(postId: String, completion: @escaping (Bool) -> Void) {
        let postRef = db.collection("challengePosts").document(postId)
        postRef.updateData(["reported": false]) { error in
            if let error = error {
                print("검토 완료 업데이트 실패: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    /// 신고된 게시물을 삭제합니다.
    func deleteReportedPost(postId: String, completion: @escaping (Bool) -> Void) {
        db.collection("challengePosts").document(postId).delete { error in
            if let error = error {
                print("게시물 삭제 실패: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
