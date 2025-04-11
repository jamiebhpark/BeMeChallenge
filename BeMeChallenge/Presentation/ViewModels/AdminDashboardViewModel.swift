// AdminDashboardViewModel.swift
import Foundation
import FirebaseFirestore
import Combine

class AdminDashboardViewModel: ObservableObject {
    @Published var reportedPostsCount: Int = 0
    @Published var pendingFriendRequestsCount: Int = 0
    @Published var feedbackCount: Int = 0
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    /// 신고된 게시물 수 조회: "challengePosts" 컬렉션에서 reported 필드가 true인 문서 수
    func fetchReportedPostsCount() {
        db.collection("challengePosts")
            .whereField("reported", isEqualTo: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    self?.errorMessage = "신고된 게시물 조회 에러: \(error.localizedDescription)"
                    return
                }
                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self?.reportedPostsCount = count
                }
            }
    }
    
    /// 대기중인 친구 요청 수 조회: "friendRequests" 컬렉션에서 status가 "pending"인 문서 수
    func fetchPendingFriendRequestsCount() {
        db.collection("friendRequests")
            .whereField("status", isEqualTo: "pending")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    self?.errorMessage = "친구 요청 조회 에러: \(error.localizedDescription)"
                    return
                }
                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self?.pendingFriendRequestsCount = count
                }
            }
    }
    
    /// 피드백 수 조회: "feedback" 컬렉션의 문서 수
    func fetchFeedbackCount() {
        db.collection("feedback")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    self?.errorMessage = "피드백 조회 에러: \(error.localizedDescription)"
                    return
                }
                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self?.feedbackCount = count
                }
            }
    }
    
    /// 모든 대시보드 데이터를 한 번에 로드합니다.
    func loadDashboardData() {
        fetchReportedPostsCount()
        fetchPendingFriendRequestsCount()
        fetchFeedbackCount()
    }
}
