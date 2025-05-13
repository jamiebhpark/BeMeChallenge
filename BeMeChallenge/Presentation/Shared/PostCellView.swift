// Presentation/Shared/PostCellView.swift
import SwiftUI
import FirebaseAuth

struct PostCellView: View {
    let post: Post
    let user: User?
    
    var onLike:   () -> Void = {}
    var onReport: () -> Void = {}
    var onDelete: () -> Void = {}
    
    var showActions: Bool = true
    
    @State private var showHeart      = false
    @State private var heartScale: CGFloat  = 0.1
    @State private var heartOpacity: Double = 0.0
    
    @EnvironmentObject private var modalC: ModalCoordinator
    
    var body: some View {
        VStack(spacing: 12) {
            header
            imageSection
            if showActions { actionBar }
            footer
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
        // 관리 알럿
        .alert(item: $modalC.modalAlert) { alert in
            switch alert {
            case .manage(let p):
                return Alert(
                    title: Text("게시물 관리"),
                    primaryButton: .destructive(Text("삭제")) {
                        onDelete()
                        modalC.resetAlert()
                        modalC.showToast(ToastItem(message: "삭제 완료"))
                    },
                    secondaryButton: .destructive(Text("신고")) {
                        modalC.showAlert(.reportConfirm(post: p))
                    }
                )
            case .deleteConfirm, .reportConfirm:
                // 실제 삭제/신고 액션은 별도 토스트에서 처리
                return Alert(title: Text("알림"))
            }
        }
    }
    
    private var header: some View {
        HStack(spacing: 12) {
            avatar
            Text(displayName).font(.subheadline.bold())
            Spacer()
            Text(post.createdAt, style: .time)
                .font(.caption).foregroundColor(.secondary)
            
            if showActions {
                Button {
                    modalC.showAlert(.manage(post: post))
                } label: {
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
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
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
    }
    
    private var actionBar: some View {
        HStack(spacing: 12) {
            Button(action: onLike) {
                Image(systemName: post.reactions["❤️", default: 0] > 0 ? "heart.fill" : "heart")
                    .font(.title2)
                    .foregroundColor(.red)
            }
            Spacer()
            Button(action: shareImmediately) {
                Image(systemName: "square.and.arrow.up").font(.title2)
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
        .padding([.horizontal, .bottom], 8)
    }
    
    private var displayName: String {
        let raw = user?.nickname.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return raw.isEmpty ? "익명" : raw
    }
    
    private func shareImmediately() {
        guard let url = URL(string: post.imageUrl) else { return }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared
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
}
