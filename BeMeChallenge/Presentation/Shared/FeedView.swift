// Presentation/Shared/FeedView.swift
import SwiftUI
import FirebaseFirestore

/// 공통 피드 컴포넌트
struct FeedView: View {
    let posts: [Post]
    let userCache: [String: User]
    let initialPostID: String?
    
    var onLike:   (Post) -> Void = { _ in }
    var onReport: (Post) -> Void = { _ in }
    var onDelete: (Post) -> Void = { _ in }
    
    private func author(for post: Post) -> User {
        userCache[post.userId] ??
        User(id: post.userId, nickname: "익명",
             bio: nil, location: nil,
             profileImageURL: nil,
             isProfilePublic: true, fcmToken: nil)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(posts, id: \.id) { post in
                        PostCellView(
                            post: post,
                            user: author(for: post),
                            onLike:   { onLike(post) },
                            onReport: { onReport(post) },
                            onDelete: { onDelete(post) }
                        )
                        .id(post.id ?? UUID().uuidString)
                        .padding(.horizontal, 12)
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onAppear {
                if let id = initialPostID {
                    proxy.scrollTo(id, anchor: .top)
                }
            }
        }
    }
}
