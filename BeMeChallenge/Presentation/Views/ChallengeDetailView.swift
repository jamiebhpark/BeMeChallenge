// ChallengeDetailView.swift
import SwiftUI

struct ChallengeDetailView: View {
    let challengeId: String
    @StateObject private var vm = ChallengeDetailViewModel()

    @State private var reportTarget: Post?
    @State private var showReport = false

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    HighlightBarView(posts: vm.posts) { post in
                        let key = post.id ?? UUID().uuidString
                        withAnimation { proxy.scrollTo(key, anchor: .top) }
                    }
                    .frame(height: 70)
                    .padding(.top, 8)

                    LazyVStack(spacing: 24) {
                        ForEach(vm.posts, id: \.id) { post in
                            let author = vm.userCache[post.userId]
                                ?? User(id: post.userId,
                                        nickname: "익명",
                                        bio: nil,
                                        location: nil,
                                        profileImageURL: nil,
                                        isProfilePublic: true,
                                        fcmToken: nil)

                            PostCellView(
                                post: post,
                                user: author,
                                onLike:   { vm.like(post) },
                                onReport: { reportTarget = post; showReport = true },
                                onDelete: { vm.deletePost(post) }
                            )
                            .id(post.id ?? UUID().uuidString)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 40)
                }
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear { vm.fetch(challengeId) }
            .alert("게시물 신고", isPresented: $showReport) {
                Button("신고", role: .destructive) {
                    if let p = reportTarget { vm.report(p) }
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("이 게시물을 신고하시겠습니까?")
            }
        }
    }
}
