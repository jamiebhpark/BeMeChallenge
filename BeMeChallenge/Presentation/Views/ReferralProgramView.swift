// ReferralProgramView.swift
import SwiftUI

struct ReferralProgramView: View {
    @StateObject var viewModel = ReferralProgramViewModel()
    @State private var isShareSheetPresented = false
    @State private var shareURL: URL?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("내 추천 코드")
                    .font(.headline)
                if let code = viewModel.referralCode {
                    Text(code)
                        .font(.title)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                } else {
                    Text("추천 코드 없음")
                }
                
                Text("초대 받은 친구: \(viewModel.referralCount)")
                    .font(.subheadline)
                Text("보상 포인트: \(viewModel.rewardPoints)")
                    .font(.subheadline)
                
                Button(action: {
                    // 공유할 URL 생성 (예시: 사용자의 추천 코드를 포함한 링크)
                    if let code = viewModel.referralCode,
                       let url = URL(string: "https://bemechallenge.com/referral?code=\(code)") {
                        shareURL = url
                        isShareSheetPresented = true
                    }
                }, label: {
                    Text("친구 초대하기")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                })
                .padding(.horizontal)
                .sheet(isPresented: $isShareSheetPresented) {
                    if let url = shareURL {
                        ActivityView(activityItems: [url])
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("추천 프로그램")
            .onAppear {
                viewModel.fetchReferralStats()
            }
        }
    }
}
