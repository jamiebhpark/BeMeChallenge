// PostCellView.swift
import SwiftUI
import FirebaseAuth

struct PostCellView: View {
    let post: Post
    let user: User?
    let onLike: () -> Void
    let onReport: () -> Void
    let onDelete: () -> Void

    @State private var showHeart = false
    @State private var heartScale: CGFloat = 0.1
    @State private var heartOpacity = 0.0
    @State private var showOptions = false

    private var displayName: String {
        let raw = user?.nickname.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return raw.isEmpty ? "익명" : raw
    }

    var body: some View {
        VStack(spacing: 12) {
            // ── 헤더 ─────────────────────────────
            HStack(spacing: 12) {
                // 1) 프로필 이미지
                if let url = user?.effectiveProfileImageURL {
                    AsyncCachedImage(
                        url: url,
                        content: { $0.resizable().scaledToFill() },
                        placeholder: { Image("defaultAvatar").resizable() },
                        failure:     { Image("defaultAvatar").resizable() }
                    )
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                } else {
                    Image("defaultAvatar")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                }

                // 2) 닉네임
                Text(displayName)
                    .font(.subheadline.bold())

                Spacer()

                // 3) 시간
                Text(post.createdAt, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)

                // 4) 옵션
                Button { showOptions = true } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .padding(.horizontal, 4)
                }
            }
            .padding([.horizontal, .top], 12)

            // ── 이미지 ─────────────────────────────
            ZStack {
                AsyncCachedImage(
                    url: URL(string: post.imageUrl),
                    content: { $0.resizable().scaledToFill() },
                    placeholder: { ProgressView() },
                    failure:     { Color(.systemGray5) }
                )
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .contentShape(Rectangle())
                .onTapGesture(count: 2) { animateLike() }

                if showHeart {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 90))
                        .foregroundColor(.white)
                        .scaleEffect(heartScale)
                        .opacity(heartOpacity)
                        .shadow(radius: 10)
                }
            }

            // ── 액션 바 ─────────────────────────────
            HStack(spacing: 12) {
                Button(action: onLike) {
                    Image(systemName: post.reactions["❤️", default: 0] > 0
                          ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                Spacer()
                Button(action: shareImmediately) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                }
            }
            .padding(4)

            // ── 좋아요 & 캡션 ───────────────────────
            VStack(alignment: .leading, spacing: 4) {
                Text("\(post.reactions["❤️", default: 0])명이 좋아합니다")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let caption = post.caption, !caption.isEmpty {
                    (Text(displayName).bold() + Text(" \(caption)"))
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
        .confirmationDialog("게시물 관리", isPresented: $showOptions) {
            if post.userId == Auth.auth().currentUser?.uid {
                Button("삭제", role: .destructive, action: onDelete)
            }
            Button("신고", role: .destructive, action: onReport)
            Button("취소", role: .cancel) {}
        }
    }

    // MARK: - Helpers

    private func shareImmediately() {
        guard let url = URL(string: post.imageUrl) else { return }
        let controller = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(controller, animated: true)
        }
    }

    private func animateLike() {
        onLike()
        heartScale = 0.2
        heartOpacity = 1
        showHeart = true
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            heartScale = 1.1
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.4)) {
            heartOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showHeart = false
        }
    }
}
