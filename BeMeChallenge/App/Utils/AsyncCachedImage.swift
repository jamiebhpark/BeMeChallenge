import SwiftUI

/// URL 기반 이미지 로더(View)
/// * 내부적으로 ImageCache를 사용해 메모리·디스크 캐싱
/// * Swift Concurrency(`async/await`) 로 네트워크 호출
struct AsyncCachedImage<Content: View,
                        Placeholder: View,
                        Failure: View>: View {

    // MARK: - Properties
    let url: URL?
    @ViewBuilder var content: (Image) -> Content
    @ViewBuilder var placeholder: () -> Placeholder
    @ViewBuilder var failure: () -> Failure

    @State private var phase: Phase = .empty

    // MARK: - Body
    var body: some View {
        switch phase {
        case .success(let img):
            content(Image(uiImage: img))
        case .failure:
            failure()
        case .empty:
            placeholder()
                .task { await load() }
        }
    }

    // MARK: - Loader
    private func load() async {
        guard let url = url else { return }
        guard case .empty = phase else { return }

        // 1) 캐시 검사
        if let cached = ImageCache.shared.image(for: url) {
            phase = .success(cached); return
        }

        // 2) 네트워크 다운로드
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let img = UIImage(data: data) else {
                phase = .failure; return
            }
            ImageCache.shared.store(img, for: url)
            phase = .success(img)
        } catch {
            phase = .failure
        }
    }

    // MARK: - Phase Enum
    private enum Phase {
        case empty
        case success(UIImage)
        case failure
    }
}

// MARK: - 편의 이니셜라이저
extension AsyncCachedImage
where Placeholder == ProgressView<EmptyView, EmptyView>,
      Failure == Image {

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.url = url
        self.content = content
        self.placeholder = { ProgressView() }
        self.failure = { Image(systemName: "photo") }
    }
}
