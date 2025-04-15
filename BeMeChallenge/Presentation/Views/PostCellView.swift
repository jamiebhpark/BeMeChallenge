// PostCellView.swift (업데이트)
import SwiftUI

struct PostCellView: View {
    var post: Post
    var reactionAction: (String) -> Void
    var reportAction: (() -> Void)?  // 신고 기능 호출 클로저

    // 사용할 이모티콘 리스트
    let reactions: [String] = ["❤️", "👍", "😆", "🔥"]

    var body: some View {
        VStack(spacing: 8) {
            // 이미지 영역: 전체 너비를 채우도록 하고 고정 높이로 표시 (인스타그램 피드 스타일)
            AsyncImage(url: URL(string: post.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .clipped()
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                @unknown default:
                    EmptyView()
                }
            }
            
            // 반응 버튼 및 신고 버튼 영역
            HStack {
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
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    }
                }
                Spacer()
                if let reportAction = reportAction {
                    Button(action: reportAction) {
                        Image(systemName: "flag.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding(.horizontal)
    }
}
