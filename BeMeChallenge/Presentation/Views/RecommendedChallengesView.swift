// RecommendedChallengesView.swift
import SwiftUI

struct RecommendedChallengesView: View {
    @StateObject var viewModel = RecommendationViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.recommendedChallenges) { challenge in
                NavigationLink(destination: ChallengeDetailView(challengeId: challenge.id)) {
                    ChallengeCardView(challenge: challenge)
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
