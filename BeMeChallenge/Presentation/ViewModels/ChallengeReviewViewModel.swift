// Presentation/ViewModels/ChallengeReviewViewModel.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class ChallengeReviewViewModel: ObservableObject {
    @Published var reviews: [ChallengeReview] = []
    @Published var averageRating: Double = 0.0
    @Published var userRating: Int = 0
    @Published var userReviewText: String = ""
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    /// 특정 챌린지에 대한 후기를 불러옵니다.
    func fetchReviews(for challengeId: String) {
        db.collection("challengeReviews")
            .whereField("challengeId", isEqualTo: challengeId)
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let fetchedReviews: [ChallengeReview] = documents.compactMap { doc in
                    try? doc.data(as: ChallengeReview.self)
                }
                DispatchQueue.main.async {
                    self?.reviews = fetchedReviews
                    self?.calculateAverageRating(from: fetchedReviews)
                }
            }
    }
    
    private func calculateAverageRating(from reviews: [ChallengeReview]) {
        let totalRating = reviews.reduce(0) { $0 + $1.rating }
        averageRating = reviews.isEmpty ? 0.0 : Double(totalRating) / Double(reviews.count)
    }
    
    /// 사용자가 새로운 후기를 제출합니다.
    func submitReview(for challengeId: String, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "사용자 정보를 찾을 수 없습니다."
            completion(false)
            return
        }
        let reviewData: [String: Any] = [
            "challengeId": challengeId,
            "userId": userId,
            "rating": userRating,
            "reviewText": userReviewText,
            "createdAt": FieldValue.serverTimestamp()
        ]
        db.collection("challengeReviews").addDocument(data: reviewData) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    completion(true)
                    self?.userRating = 0
                    self?.userReviewText = ""
                    self?.fetchReviews(for: challengeId)
                }
            }
        }
    }
}
