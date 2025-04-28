//ChallengeDetailView.swift
import SwiftUI
import FirebaseFirestore
import Combine

@MainActor
final class ChallengeDetailViewModel: ObservableObject {
    /// 원본 피드 포스트
    @Published var posts: [Post] = []
    /// userId ↔ User 매핑 (nickname, profileImageURL 등)
    @Published var userCache: [String: User] = [:]

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let userRepo: UserRepositoryProtocol = UserRepository()

    /// 실시간 피드 구독 시작
    func fetch(_ challengeId: String) {
        listener?.remove()
        listener = db.collection("challengePosts")
            .whereField("challengeId", isEqualTo: challengeId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                guard let self = self else { return }
                if let err = err {
                    print("fetch err:", err)
                    return
                }

                // 1) Post 배열 갱신
                let docs = snap?.documents ?? []
                self.posts = docs.compactMap { doc in
                    let d = doc.data()
                    guard
                        let userId   = d["userId"]   as? String,
                        let imageUrl = d["imageUrl"] as? String,
                        let ts       = d["createdAt"] as? Timestamp,
                        let react    = d["reactions"] as? [String:Int],
                        let reported = d["reported"]  as? Bool
                    else { return nil }

                    return Post(
                        id: doc.documentID,
                        challengeId: challengeId,
                        userId: userId,
                        imageUrl: imageUrl,
                        createdAt: ts.dateValue(),
                        reactions: react,
                        reported: reported,
                        caption: d["caption"] as? String
                    )
                }

                // 2) 누락된 userId만 모아서 fetch
                let missingIds = Set(self.posts.map { $0.userId })
                    .subtracting(self.userCache.keys)
                if !missingIds.isEmpty {
                    self.userRepo.fetchUsers(withIds: Array(missingIds)) { result in
                        switch result {
                        case .success(let users):
                            DispatchQueue.main.async {
                                for user in users {
                                    self.userCache[user.id] = user
                                }
                            }
                        case .failure(let error):
                            print("Failed fetching users:", error.localizedDescription)
                        }
                    }
                }
            }
    }

    /// ❤️ 반응
    func like(_ post: Post) {
        ReactionService.shared.updateReaction(
            forPost: post.id!,
            reactionType: "❤️",
            userId: post.userId
        ) { _ in }
    }

    /// 신고
    func report(_ post: Post) {
        ReportService.shared.reportPost(postId: post.id!) { _ in }
    }

    /// 삭제
    func deletePost(_ post: Post) {
        db.collection("challengePosts").document(post.id!).delete { [weak self] err in
            if let err = err {
                print("delete err:", err.localizedDescription)
            } else {
                self?.posts.removeAll { $0.id == post.id }
            }
        }
    }

    deinit { listener?.remove() }
}
