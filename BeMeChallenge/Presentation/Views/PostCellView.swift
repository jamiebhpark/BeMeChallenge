// PostCellView.swift (업데이트)
import SwiftUI

struct PostCellView: View {
    var post: Post
    var reactionAction: (String) -> Void
    var reportAction: (() -> Void)?  // 신고 기능 호출 클로저
    
    // 사용할 이모티콘 리스트
    let reactions: [String] = ["❤️", "👍", "😆", "🔥"]
    
    var body: some View {
        VStack(spacing: 4) {
            // 이미지 로딩 (AsyncImage 사용)
            AsyncImage(url: URL(string: post.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: 150)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .clipped()
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 150)
                @unknown default:
                    EmptyView()
                }
            }
            
            // 반응 버튼과 신고 버튼을 포함한 HStack
            HStack(spacing: 8) {
                ForEach(reactions, id: \.self) { reaction in
                    Button(action: {
                        reactionAction(reaction)
                    }) {
                        HStack(spacing: 4) {
                            Text(reaction)
                            Text("\(post.reactions[reaction] ?? 0)")
                                .font(.caption2)
                        }
                        .padding(6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
                Spacer()
                // 신고 버튼 (reportAction이 전달된 경우만 표시)
                if let reportAction = reportAction {
                    Button(action: reportAction) {
                        Image(systemName: "flag.fill")
                            .foregroundColor(.red)
                    }
                    .padding(4)
                }
            }
            .padding(4)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct PostCellView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePost = Post(
            id: "post1",
            challengeId: "challenge1",
            userId: "user1",
            imageUrl: "https://example.com/sample.jpg",
            createdAt: Date(),
            reactions: ["❤️": 5, "👍": 3, "😆": 2, "🔥": 1],
            reported: false
        )
        PostCellView(post: samplePost, reactionAction: { reaction in
            print("Reaction: \(reaction)")
        }, reportAction: {
            print("Report action triggered")
        })
        .previewLayout(.sizeThatFits)
    }
}
