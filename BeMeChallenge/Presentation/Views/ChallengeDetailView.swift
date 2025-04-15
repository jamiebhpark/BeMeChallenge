// ChallengeDetailView.swift (업데이트)
import SwiftUI

struct ChallengeDetailView: View {
    var challengeId: String
    @StateObject var viewModel = ChallengeDetailViewModel()
    @State private var showReportAlert = false
    @State private var selectedPostId: String? = nil

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.posts) { post in
                    PostCellView(
                        post: post,
                        reactionAction: { reaction in
                            ReactionService.shared.updateReaction(
                                forPost: post.id,
                                reactionType: reaction,
                                userId: post.userId
                            ) { result in
                                switch result {
                                case .success:
                                    print("Reaction updated")
                                case .failure(let error):
                                    print("Error updating reaction: \(error.localizedDescription)")
                                }
                            }
                        },
                        reportAction: {
                            selectedPostId = post.id
                            showReportAlert = true
                        }
                    )
                }
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("챌린지 콘텐츠")
        .onAppear {
            viewModel.fetchPosts(forChallenge: challengeId)
        }
        .alert(isPresented: $showReportAlert) {
            Alert(
                title: Text("게시물 신고"),
                message: Text("이 게시물을 신고하시겠습니까?"),
                primaryButton: .destructive(Text("신고")) {
                    if let postId = selectedPostId {
                        ReportService.shared.reportPost(postId: postId) { result in
                            switch result {
                            case .success:
                                print("Post reported successfully.")
                            case .failure(let error):
                                print("Error reporting post: \(error.localizedDescription)")
                            }
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}
