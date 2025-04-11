// ReportManagementView.swift
import SwiftUI

struct ReportManagementView: View {
    @StateObject var viewModel = ReportManagementViewModel()
    @State private var showActionSheet = false
    @State private var selectedPostId: String?
    @State private var actionSheetType: ActionType = .none
    
    enum ActionType {
        case markReviewed, delete
        case none
    }
    
    var body: some View {
        NavigationView {
            List(viewModel.reportedPosts) { post in
                HStack {
                    if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 60, height: 60)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipped()
                                    .cornerRadius(8)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 60, height: 60)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("챌린지: \(post.challengeId)")
                            .font(.subheadline)
                        Text("작성자: \(post.userId)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        if let date = post.createdAt {
                            Text(date, style: .date)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    Button(action: {
                        selectedPostId = post.id
                        actionSheetType = .markReviewed
                        showActionSheet = true
                    }) {
                        Text("검토 완료")
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing, 8)
                    
                    Button(action: {
                        selectedPostId = post.id
                        actionSheetType = .delete
                        showActionSheet = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("신고 관리")
            .onAppear {
                viewModel.fetchReportedPosts()
            }
            .actionSheet(isPresented: $showActionSheet) {
                actionSheet()
            }
        }
    }
    
    private func actionSheet() -> ActionSheet {
        ActionSheet(title: Text("신고 처리"), message: Text("선택한 게시물을 처리하시겠습니까?"), buttons: [
            .default(Text("검토 완료")) {
                if let postId = selectedPostId {
                    viewModel.markAsReviewed(postId: postId) { success in
                        if success {
                            viewModel.fetchReportedPosts()
                        }
                    }
                }
            },
            .destructive(Text("삭제")) {
                if let postId = selectedPostId {
                    viewModel.deleteReportedPost(postId: postId) { success in
                        if success {
                            viewModel.fetchReportedPosts()
                        }
                    }
                }
            },
            .cancel(Text("취소"))
        ])
    }
}

struct ReportManagementView_Previews: PreviewProvider {
    static var previews: some View {
        ReportManagementView()
    }
}
