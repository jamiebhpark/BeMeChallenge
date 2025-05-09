// Presentation/Views/UserPostListView.swift
import SwiftUI

struct UserPostListView: View {
    @ObservedObject var profileVM: ProfileViewModel
    let initialPostID: String?

    private let spacing: CGFloat = 16

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: spacing) {
                    ForEach(profileVM.userPosts) { post in
                        PostCellWrapper(post: post)
                            .id(post.id ?? UUID().uuidString)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical, spacing)
            }
            .onAppear {
                // 탭했던 포스트로 자동 스크롤
                if let id = initialPostID {
                    proxy.scrollTo(id, anchor: .top)
                }
            }
        }
        .navigationTitle("내 포스트")
        .navigationBarTitleDisplayMode(.inline)
    }
}
