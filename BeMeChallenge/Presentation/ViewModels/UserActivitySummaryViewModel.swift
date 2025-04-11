// UserActivitySummaryViewModel.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class UserActivitySummaryViewModel: ObservableObject {
    @Published var challengeParticipationCount: Int = 0
    @Published var postUploadCount: Int = 0
    @Published var reviewCount: Int = 0
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    /// Firestore의 "users/{userId}" 도큐먼트에서 활동 요약 정보를 읽어옵니다.
    func fetchUserActivitySummary() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "사용자 정보를 찾을 수 없습니다."
            return
        }
        
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { [weak self] snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                return
            }
            guard let data = snapshot?.data() else { return }
            DispatchQueue.main.async {
                self?.challengeParticipationCount = data["challengeParticipationCount"] as? Int ?? 0
                self?.postUploadCount = data["postUploadCount"] as? Int ?? 0
                self?.reviewCount = data["reviewCount"] as? Int ?? 0
            }
        }
    }
}
