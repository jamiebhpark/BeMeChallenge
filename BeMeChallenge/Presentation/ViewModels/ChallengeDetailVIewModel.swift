// Presentation/ViewModels/ChallengeDetailViewModel.swift
import Foundation
import FirebaseFirestore
import Combine

class ChallengeDetailViewModel: ObservableObject {
    @Published var posts: [Post] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func fetchPosts(forChallenge challengeId: String) {
        listener?.remove()
        listener = db.collection("challengePosts")
            .whereField("challengeId", isEqualTo: challengeId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching posts: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self.posts = documents.compactMap { doc in
                    let data = doc.data()
                    guard let userId = data["userId"] as? String,
                          let imageUrl = data["imageUrl"] as? String,
                          let createdAtTimestamp = data["createdAt"] as? Timestamp,
                          let reactions = data["reactions"] as? [String: Int],
                          let reported = data["reported"] as? Bool
                    else { return nil }
                    return Post(id: doc.documentID,
                                challengeId: challengeId,
                                userId: userId,
                                imageUrl: imageUrl,
                                createdAt: createdAtTimestamp.dateValue(),
                                reactions: reactions,
                                reported: reported)
                }
            }
    }
    
    deinit {
        listener?.remove()
    }
}
