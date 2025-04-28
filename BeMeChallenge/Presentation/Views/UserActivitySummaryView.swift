// UserActivitySummaryView.swift
import SwiftUI

struct UserActivitySummaryView: View {
    @StateObject var viewModel = UserActivitySummaryViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let error = viewModel.errorMessage {
                    Text("오류: \(error)")
                        .foregroundColor(.red)
                }
                
                HStack(spacing: 16) {
                    ActivityTile(title: "챌린지 참여", count: viewModel.challengeParticipationCount)
                    ActivityTile(title: "업로드", count: viewModel.postUploadCount)
                    ActivityTile(title: "후기", count: viewModel.reviewCount)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("내 활동 요약")
            .onAppear {
                viewModel.fetchUserActivitySummary()
            }
        }
    }
}

/// 각 활동 항목을 표시하는 커스텀 뷰
struct ActivityTile: View {
    var title: String
    var count: Int
    
    var body: some View {
        VStack {
            Text("\(count)")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(title)
                .font(.headline)
        }
        .frame(width: 100, height: 100)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}
