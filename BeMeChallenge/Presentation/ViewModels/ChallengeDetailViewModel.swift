//
//  ChallengeDetailViewModel.swift
//  BeMeChallenge
//
//  - 로그아웃 시 리스너 해제
//  - Optional 안전 처리 (post.id 언랩만 필요, userId는 String 타입 그대로 사용)
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class ChallengeDetailViewModel: ObservableObject {
    
    // MARK: - Published
    @Published private(set) var postsState: Loadable<[Post]> = .idle
    @Published private(set) var userCache: [String: User] = [:]
    
    // MARK: - Private
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let userRepo: UserRepositoryProtocol = UserRepository()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init() {
        NotificationCenter.default.publisher(for: .didSignOut)
            .sink { [weak self] _ in
                Task { @MainActor in self?.cancelListener() }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public API
    func fetch(_ challengeId: String) {
        cancelListener()
        postsState = .loading
        
        listener = db.collection("challengePosts")
            .whereField("challengeId", isEqualTo: challengeId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err { self.postsState = .failed(err); return }
                
                let posts = snap?.documents.compactMap {
                    Self.mapDoc($0, challengeId: challengeId)
                } ?? []
                
                self.postsState = .loaded(posts)
                self.prefetchAuthors(from: posts)
            }
    }
    
    func like(_ post: Post) {
        guard let postId = post.id else { return }
        ReactionService.shared.updateReaction(
            forPost: postId,
            reactionType: "❤️",
            userId: post.userId
        ) { _ in }
    }
    
    func report(_ post: Post) {
        guard let postId = post.id else { return }
        ReportService.shared.reportPost(postId: postId) { _ in }
    }
    
    func deletePost(_ post: Post) {
        guard let postId = post.id else { return }
        db.collection("challengePosts").document(postId).delete { [weak self] err in
            if let err { print("delete err:", err.localizedDescription); return }
            guard case .loaded(var list) = self?.postsState else { return }
            list.removeAll { $0.id == postId }
            self?.postsState = .loaded(list)
        }
    }
    
    // MARK: - Listener 종료
    private func cancelListener() {
        listener?.remove(); listener = nil
        postsState = .idle
        userCache.removeAll()
    }
    
    // MARK: - Helpers
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
        
        // --- Optional → NonOptional 변환 ----------
        let caption = d["caption"] as? String ?? ""
        //-------------------------------------------
        
        return Post(
            id: doc.documentID,
            challengeId: challengeId,
            userId: userId,
            imageUrl: imageUrl,
            createdAt: ts.dateValue(),
            reactions: react,
            reported: reported,
            caption: caption                 // ← String
        )
    }
    
    private func prefetchAuthors(from posts: [Post]) {
        let missing = Set(posts.map { $0.userId }).subtracting(userCache.keys)
        guard !missing.isEmpty else { return }
        
        userRepo.fetchUsers(withIds: Array(missing)) { [weak self] result in
            guard let self = self else { return }
            if case .success(let users) = result {
                for u in users {
                    if let uid = u.id {          // ← Optional → String 언랩
                        self.userCache[uid] = u
                    }
                }
            }
        }
    }
}
