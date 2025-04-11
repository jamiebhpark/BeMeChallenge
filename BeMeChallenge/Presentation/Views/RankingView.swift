// RankingView.swift
import SwiftUI

struct RankingView: View {
    @StateObject var viewModel = RankingViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.rankingUsers) { user in
                HStack {
                    Text(user.nickname)
                        .font(.headline)
                    Spacer()
                    Text("\(user.participationCount)회 참여")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("챌린지 랭킹")
            .onAppear {
                viewModel.fetchRanking()
            }
        }
    }
}

struct RankingView_Previews: PreviewProvider {
    static var previews: some View {
        RankingView()
    }
}
