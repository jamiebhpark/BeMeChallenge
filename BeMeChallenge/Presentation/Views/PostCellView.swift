// PostCellView.swift

import SwiftUI
import FirebaseAuth

struct PostCellView: View {
    // 필수
    let post: Post
    let user: User?

    // 액션 콜백 (기본 빈 클로저)
    var onLike:    () -> Void = {}
    var onReport:  () -> Void = {}
    var onDelete:  () -> Void = {}

    // 👉 상세 화면에서 버튼을 숨길 수 있는 플래그
    var showActions: Bool = true

    // ♥ 애니메이션 상태값
    @State private var showHeart     = false
    @State private var heartScale: CGFloat  = 0.1
    @State private var heartOpacity: Double = 0.0
    @State private var showOptions   = false

    // 닉네임 가공
    private var displayName: String {
        let raw = user?.nickname.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return raw.isEmpty ? "익명" : raw
    }

    // MARK: - View
    var body: some View {
        VStack(spacing: 12) {
            // ── 헤더 ───────────────────────────────────────────────
            header

            // ── 이미지(더블탭 ♥) ────────────────────────────────
            imageSection

            // ── 액션 바 (♥ / 공유) ─────────────────────────────
            if showActions { actionBar }

            // ── 리액션 + 캡션 ───────────────────────────────────
            footer
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
        .confirmationDialog("게시물 관리", isPresented: $showOptions) {
            if showActions, post.userId == Auth.auth().currentUser?.uid {
                Button("삭제", role: .destructive, action: onDelete)
            }
            if showActions {
                Button("신고", role: .destructive, action: onReport)
            }
            Button("취소", role: .cancel) {}
        }
    }

    // MARK: - Sub-Views
    private var header: some View {
        HStack(spacing: 12) {
            avatar
            Text(displayName).font(.subheadline.bold())
            Spacer()
            Text(post.createdAt, style: .time)
                .font(.caption).foregroundColor(.secondary)
            if showActions {
                Button { showOptions = true } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .padding(.horizontal, 4)
                }
            }
        }
        .padding([.horizontal, .top], 12)
    }

    private var avatar: some View {
        Group {
            if let url = user?.effectiveProfileImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:   ProgressView()
                    case .failure: Image("defaultAvatar").resizable()
                    case .success(let img): img.resizable().scaledToFill()
                    @unknown default: EmptyView()
                    }
                }
                .id(url)
            } else {
                Image("defaultAvatar").resizable()
            }
        }
        .frame(width: 32, height: 32)
        .clipShape(Circle())
    }

    private var imageSection: some View {
        ZStack {
            AsyncCachedImage(
                url: URL(string: post.imageUrl),
                content: { $0.resizable().scaledToFill() },
                placeholder: { ProgressView() },
                failure:     { Color(.systemGray5) }
            )
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .contentShape(Rectangle())
            .onTapGesture(count: 2) { if showActions { animateLike() } }

            // ♥ 애니메이션
            if showHeart {
                Image(systemName: "heart.fill")
                    .font(.system(size: 90))
                    .foregroundColor(.white)
                    .scaleEffect(heartScale)
                    .opacity(heartOpacity)
                    .shadow(radius: 10)
            }
        }
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button(action: onLike) {
                Image(systemName:
                      post.reactions["❤️", default: 0] > 0 ? "heart.fill" : "heart")
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
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(post.reactions["❤️", default: 0])명이 좋아합니다")
                .font(.subheadline.bold())

            if let caption = post.caption, !caption.isEmpty {
                (Text(displayName).bold() + Text(" \(caption)"))
                    .font(.subheadline)
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }

    // MARK: - Helpers
    private func shareImmediately() {
        guard let url = URL(string: post.imageUrl) else { return }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication
            .shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first?
            .present(vc, animated: true)
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
    private struct ChallengeImage: View {
        let url: URL?
        @Binding var showHeart: Bool
        @Binding var heartScale: CGFloat
        @Binding var heartOpacity: Double
        var onDoubleTap: () -> Void

        var body: some View {
            ZStack {
                AsyncCachedImage(
                    url: url,
                    content: { $0.resizable().scaledToFill() },
                    placeholder: { ProgressView() },
                    failure:     { Color(.systemGray5) }
                )
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                .contentShape(Rectangle())
                .onTapGesture(count: 2, perform: onDoubleTap)

                if showHeart {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 90))
                        .foregroundColor(.white)
                        .scaleEffect(heartScale)
                        .opacity(heartOpacity)
                        .shadow(radius: 10)
                }
            }
        }
    }
}

