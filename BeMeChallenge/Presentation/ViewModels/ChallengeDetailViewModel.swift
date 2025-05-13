// Presentation/ViewModels/ChallengeDetailViewModel.swift
import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class ChallengeDetailViewModel: ObservableObject {
    
    // MARK: Published
    @Published private(set) var postsState: Loadable<[Post]> = .idle
    @Published private(set) var userCache:  [String: User]   = [:]
    
    // MARK: Private
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let userRepo: UserRepositoryProtocol = UserRepository()
    
    // MARK: – Public API
    func fetch(_ challengeId: String) {
        postsState = .loading
        listener?.remove()
        listener = db.collection("challengePosts")
            .whereField("challengeId", isEqualTo: challengeId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err { self.postsState = .failed(err); return }
                let docs  = snap?.documents ?? []
                let posts = docs.compactMap { Self.mapDoc($0, challengeId: challengeId) }
                self.postsState = .loaded(posts)
                self.prefetchAuthors(from: posts)
            }
    }
    
    func like(_ post: Post) {
        ReactionService.shared.updateReaction(
            forPost: post.id!, reactionType: "❤️", userId: post.userId) { _ in }
    }
    
    func report(_ post: Post) {
        ReportService.shared.reportPost(postId: post.id!) { _ in }
    }
    
    func deletePost(_ post: Post) {
        db.collection("challengePosts").document(post.id!).delete { [weak self] err in
            if let err { print("delete err:", err.localizedDescription); return }
            guard case .loaded(var list) = self?.postsState else { return }
            list.removeAll { $0.id == post.id }
            self?.postsState = .loaded(list)
        }
    }
    
    deinit { listener?.remove() }
    
    // MARK: – Helpers
    private static func mapDoc(_ doc: QueryDocumentSnapshot,
                               challengeId: String) -> Post? {
        let d = doc.data()
        guard
            let userId   = d["userId"]   as? String,
            let imageUrl = d["imageUrl"] as? String,
            let ts       = d["createdAt"] as? Timestamp,
            let react    = d["reactions"] as? [String:Int],
            let reported = d["reported"]  as? Bool
        else { return nil }
        
        return Post(
            id: doc.documentID, challengeId: challengeId, userId: userId,
            imageUrl: imageUrl, createdAt: ts.dateValue(),
            reactions: react, reported: reported,
            caption: d["caption"] as? String
        )
    }
    
    private func prefetchAuthors(from posts: [Post]) {
        let missing = Set(posts.map { $0.userId }).subtracting(userCache.keys)
        guard !missing.isEmpty else { return }
        userRepo.fetchUsers(withIds: Array(missing)) { [weak self] result in
            if case .success(let users) = result {
                for u in users { self?.userCache[u.id] = u }
            }
        }
    }
}
