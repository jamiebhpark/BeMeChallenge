// Presentation/Views/PostCellWrapper.swift

import SwiftUI

/// PostCellView에 User 데이터를 로드한 뒤,
/// ChallengeDetailViewModel의 액션 메서드를 호출하도록 래핑한 뷰입니다.
struct PostCellWrapper: View {
    let post: Post
    @StateObject private var userVM: UserMiniVM
    @ObservedObject private var viewModel: ChallengeDetailViewModel

    init(post: Post, viewModel: ChallengeDetailViewModel) {
        self.post = post
        _userVM = StateObject(wrappedValue: UserMiniVM(userId: post.userId))
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            if let user = userVM.user {
                PostCellView(
                    post: post,
                    user: user,
                    // ChallengeDetailViewModel의 메서드를 그대로 호출
                    onLike:   { viewModel.like(post) },
                    onReport: { viewModel.report(post) },
                    onDelete: { viewModel.deletePost(post) },
                    showActions: true
                )
                .padding(.vertical, 8)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 300)
            }
        }
    }
}
