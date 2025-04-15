import SwiftUI

struct RecommendedChallengesView: View {
    @StateObject var viewModel = RecommendationViewModel()
    @StateObject var challengeVM = ChallengeViewModel()  // 공유 인스턴스
    @StateObject var participationCoordinator = ParticipationCoordinator()  // 참여 코디네이터 추가
        
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.recommendedChallenges) { challenge in
                    NavigationLink(
                        destination: ChallengeDetailView(challengeId: challenge.id)
                    ) {
                        ChallengeCardView(challenge: challenge,
                                          viewModel: challengeVM,
                                          participationCoordinator: participationCoordinator)
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
