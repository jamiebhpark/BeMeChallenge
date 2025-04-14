// RecommendedChallengesView.swift
import SwiftUI

struct RecommendedChallengesView: View {
    @StateObject var viewModel = RecommendationViewModel()
    @StateObject var challengeVM = ChallengeViewModel()  // 공유 인스턴스
        
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.recommendedChallenges) { challenge in
                    NavigationLink(
                        destination: ChallengeDetailView(
                            challengeId: challenge.id,
                        )
                    ) {
                        ChallengeCardView(challenge: challenge, viewModel: challengeVM)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("추천 챌린지")
            .onAppear {
                viewModel.fetchRecommendedChallenges()
            }
        }
    }
}

struct RecommendedChallengesView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendedChallengesView()
    }
}

