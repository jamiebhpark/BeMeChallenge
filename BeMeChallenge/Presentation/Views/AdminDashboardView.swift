// AdminDashboardView.swift
import SwiftUI

struct AdminDashboardView: View {
    @StateObject var viewModel = AdminDashboardViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                HStack(spacing: 16) {
                    DashboardTile(title: "신고된 게시물", value: "\(viewModel.reportedPostsCount)")
                    DashboardTile(title: "대기중인 친구 요청", value: "\(viewModel.pendingFriendRequestsCount)")
                }
                DashboardTile(title: "총 피드백 수", value: "\(viewModel.feedbackCount)")
                
                Spacer()
            }
            .padding()
            .navigationTitle("관리자 대시보드")
            .onAppear {
                viewModel.loadDashboardData()
            }
        }
    }
}

struct DashboardTile: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .frame(width: 150, height: 150)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct AdminDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        AdminDashboardView()
    }
}
