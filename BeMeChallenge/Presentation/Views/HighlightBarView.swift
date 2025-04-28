// HighlightBarView.swift
import SwiftUI

/// 🔝 좋아요가 많은 순으로 10개까지 썸네일을 보여주는 하이라이트 바
struct HighlightBarView: View {
    /// `ChallengeDetailViewModel` 에서 내려받는 전체 포스트
    let posts: [Post]
    /// 썸네일 탭 시 호출: 호출처에서 scrollTo(post) 등으로 핸들링
    let onSelect: (Post) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(popularPosts.prefix(10)) { post in
                    ZStack(alignment: .bottomTrailing) {
                        /* 썸네일 */
                        AsyncCachedImage(
                            url: URL(string: post.imageUrl),
                            content: { img in
                                img.resizable()
                                   .scaledToFill()
                                   .overlay(Color.black.opacity(0.15))   // 밝은 이미지 대비용
                            },
                            placeholder: { Color(.systemGray5) },
                            failure:     { Color(.systemGray5) }
                        )

                        .frame(width: 76, height: 76)   // 살짝 안쪽으로
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .onTapGesture { onSelect(post) }
                        .accessibilityLabel(Text("좋아요 \(totalLikes(post))개, 게시물 열기"))
                        
                        /* ❤️ + 숫자 배지 */
                        HStack(spacing: 2) {
                            Image(systemName: "heart.fill")
                                .font(.caption2).foregroundColor(.white.opacity(0.9))
                            Text("\(totalLikes(post))")
                                .font(.caption2).bold()
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(
                            Capsule().fill(Color.red.opacity(0.9))
                        )
                        .offset(x: -4, y: -4)
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 70)   // 70 pt (썸네일 76 – 오버랩 느낌)
    }
    
    // MARK: - Helpers
    private func totalLikes(_ post: Post) -> Int {
        post.reactions["❤️", default: 0]
    }
    private var popularPosts: [Post] {
        posts.sorted { totalLikes($0) > totalLikes($1) }
    }
}
