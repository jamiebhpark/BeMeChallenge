// RewardsView.swift
import SwiftUI

struct RewardsView: View {
    @StateObject var viewModel = RewardsViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("현재 보유 포인트")
                    .font(.headline)
                Text("\(viewModel.points)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                // 아래 버튼은 테스트용으로, 실제 서비스에서는 챌린지 참여 시 자동으로 포인트가 추가되도록 구현 가능
                Button(action: {
                    viewModel.addReward(points: 10)
                }) {
                    Text("포인트 추가하기 (테스트)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("보상 시스템")
            .onAppear {
                viewModel.loadPoints()
            }
        }
    }
}

struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        RewardsView()
    }
}
