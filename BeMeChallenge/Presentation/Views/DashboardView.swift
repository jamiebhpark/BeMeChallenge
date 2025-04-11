// DashboardView.swift
import SwiftUI

struct DashboardView: View {
    @StateObject var streakViewModel = StreakViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("현재 챌린지 스트릭")
                    .font(.headline)
                Text("\(streakViewModel.currentStreak)일")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                NavigationLink(destination: RankingView()) {
                    Text("챌린지 랭킹 보기")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("대시보드")
            .onAppear {
                streakViewModel.fetchAndCalculateStreak()
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
