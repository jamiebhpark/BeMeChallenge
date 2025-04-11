// Presentation/ViewModels/FeedViewModel.swift
import Foundation
import FirebaseFirestore
import Combine

class FeedViewModel: ObservableObject {
    @Published var feedItems: [FeedItem] = []
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    /// Firestore의 "activityFeed" 컬렉션에서 피드 항목을 실시간으로 조회합니다.
    func fetchFeed() {
        listener?.remove()
        listener = db.collection("activityFeed")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("피드 항목 조회 에러: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let items: [FeedItem] = documents.compactMap { doc in
                    try? doc.data(as: FeedItem.self)
                }
                DispatchQueue.main.async {
                    self?.feedItems = items
                }
            }
    }
    
    deinit {
        listener?.remove()
    }
}
